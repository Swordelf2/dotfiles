local rpc = require("./rpc.luau")
local pending = false

local function speed(bytes)
	local value = tonumber(bytes) or 0
	if value >= 1000000 then
		return string.format("%.1f MB/s", value / 1000000)
	elseif value >= 1000 then
		return string.format("%.0f KB/s", value / 1000)
	end
	return string.format("%.0f B/s", value)
end

barWidget.setGlyph("download")
barWidget.setText("")
noctalia.setUpdateInterval(2000)

function update()
	if pending then
		return
	end

	pending = true
	rpc.call("aria2.getGlobalStat", {}, function(result, err)
		pending = false
		if err then
			barWidget.setText("!")
			return
		end

		local running = tonumber(result.numActive) or 0
		if running == 0 then
			barWidget.setText("")
		else
			barWidget.setText(speed(result.downloadSpeed) .. " · " .. running)
		end
	end)
end

function onClick()
	noctalia.togglePanel("swordelf/aria2:downloads")
end
