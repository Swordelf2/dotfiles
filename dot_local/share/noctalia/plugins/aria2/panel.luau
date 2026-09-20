local rpc = require("./rpc.luau")
local active = {}
local waiting = {}
local totalSpeed = 0
local running = 0
local currentLimit = "7 MB/s"
local link = ""
local limitInput = "7"
local message = ""
local opened = false
local pending = false
local openCount = 0

local function speed(bytes)
	local value = tonumber(bytes) or 0
	if value >= 1000000 then
		return string.format("%.1f MB/s", value / 1000000)
	elseif value >= 1000 then
		return string.format("%.0f KB/s", value / 1000)
	end
	return string.format("%.0f B/s", value)
end

local function limitLabel(raw)
	local amount, unit = string.match(raw or "", "^(%d+%.?%d*)([KkMm]?)$")
	local bytes = tonumber(amount) or 0
	if unit == "K" or unit == "k" then
		bytes = bytes * 1024
	elseif unit == "M" or unit == "m" then
		bytes = bytes * 1024 * 1024
	end
	return bytes == 0 and "Unlimited" or speed(bytes)
end

local function downloadName(item)
	local torrent = item.bittorrent and item.bittorrent.info
	if torrent and torrent.name and torrent.name ~= "" then
		return torrent.name
	end
	local file = item.files and item.files[1]
	local path = file and file.path or ""
	local name = string.match(path, "([^/]+)$")
	if name and name ~= "" then
		return name
	end
	local uri = file and file.uris and file.uris[1] and file.uris[1].uri or ""
	local cleanUri = string.gsub(uri, "[?#].*$", "")
	return string.match(cleanUri, "/([^/]+)$") or item.gid
end

local render
local refresh

local function perform(method, args, success)
	rpc.call(method, args, function(_, err)
		message = err or success
		if opened then
			render()
			refresh()
		end
	end)
end

local function downloadRow(item)
	local length = tonumber(item.totalLength) or 0
	local done = tonumber(item.completedLength) or 0
	local progress = length > 0 and math.min(done / length, 1) or 0
	local paused = item.status == "paused"
	local action = paused and "Resume" or "Pause"
	local method = paused and "aria2.unpause" or "aria2.pause"
	local detail = string.format("%.0f%%", progress * 100)
	if item.status == "active" then
		detail = detail .. " · " .. speed(item.downloadSpeed)
	else
		detail = detail .. " · " .. item.status
	end

	return ui.column({ key = item.gid, gap = 4, padding = 8, fill = "surface_variant", radius = 10 }, {
		ui.row({ align = "center", gap = 8 }, {
			ui.label({ text = downloadName(item), fontWeight = "semibold", maxLines = 1, flexGrow = 1 }),
			ui.button({ text = action, controlSize = "sm", variant = "ghost", onClick = function()
				perform(method, { item.gid }, action .. " requested")
			end }),
		}),
		ui.progress({ progress = progress }),
		ui.label({ text = detail, fontSize = 12, color = "on_surface_variant" }),
	})
end

render = function()
	if not opened then
		return
	end

	local rows = {}
	for _, item in ipairs(active) do
		table.insert(rows, downloadRow(item))
	end
	for _, item in ipairs(waiting) do
		table.insert(rows, downloadRow(item))
	end
	if #rows == 0 then
		table.insert(rows, ui.label({ text = "No downloads", color = "on_surface_variant" }))
	end

	panel.render(ui.column({ gap = 12, flexGrow = 1, align = "stretch" }, {
		ui.row({ align = "center", gap = 8 }, {
			ui.glyph({ name = "download", size = 20, color = "primary" }),
			ui.label({ text = "Downloads", fontSize = 18, fontWeight = "bold", flexGrow = 1 }),
			ui.button({ glyph = "refresh", controlSize = "sm", variant = "ghost", onClick = function() refresh() end }),
		}),
		ui.label({ text = string.format("%s  ·  %d running", speed(totalSpeed), running), color = "on_surface_variant" }),
		ui.row({ gap = 8, align = "center" }, {
			ui.input({ key = "link-" .. openCount, placeholder = "Paste a download link", value = link,
				flexGrow = 1, onChange = function(value) link = value end, onSubmit = "addDownload" }),
			ui.button({ text = "Add", variant = "primary", controlSize = "sm", onClick = function()
				addDownload()
			end }),
		}),
		ui.row({ gap = 8, align = "center" }, {
			ui.label({ text = "Limit (MB/s)" }),
			ui.input({ key = "limit-" .. openCount, value = limitInput, width = 68,
				onChange = function(value) limitInput = value end, onSubmit = "setLimit" }),
			ui.button({ text = "Set", controlSize = "sm", onClick = function()
				setLimit()
			end }),
			ui.button({ text = "Unlimited", controlSize = "sm", variant = "ghost", onClick = "removeLimit" }),
		}),
		ui.label({ text = "Current limit: " .. currentLimit, fontSize = 12, color = "on_surface_variant" }),
		ui.row({ gap = 8 }, {
			ui.button({ text = "Pause all", controlSize = "sm", variant = "ghost", onClick = function()
				perform("aria2.pauseAll", {}, "All downloads paused")
			end }),
			ui.button({ text = "Resume all", controlSize = "sm", variant = "ghost", onClick = function()
				perform("aria2.unpauseAll", {}, "All downloads resumed")
			end }),
		}),
		ui.separator({}),
		ui.scroll({ gap = 8, flexGrow = 1 }, rows),
		ui.label({ text = message, maxLines = 2, fontSize = 12, color = "on_surface_variant" }),
	}))
end

refresh = function()
	if pending or not opened then
		return
	end
	pending = true

	local function fail(err)
		pending = false
		message = err
		active = {}
		waiting = {}
		running = 0
		totalSpeed = 0
		render()
	end

	rpc.call("aria2.getGlobalStat", {}, function(stat, err)
		if err then fail(err); return end
		running = tonumber(stat.numActive) or 0
		totalSpeed = tonumber(stat.downloadSpeed) or 0
		local waitingCount = tonumber(stat.numWaiting) or 0
		rpc.call("aria2.getGlobalOption", {}, function(options, optionError)
			if optionError then fail(optionError); return end
			currentLimit = limitLabel(options["max-overall-download-limit"])
			local keys = { "gid", "status", "totalLength", "completedLength", "downloadSpeed", "files", "bittorrent" }
			rpc.call("aria2.tellActive", { keys }, function(activeResult, activeError)
				if activeError then fail(activeError); return end
				active = activeResult or {}
				if waitingCount == 0 then
					waiting = {}
					pending = false
					render()
					return
				end
				rpc.call("aria2.tellWaiting", { 0, waitingCount, keys }, function(waitingResult, waitingError)
					if waitingError then fail(waitingError); return end
					waiting = waitingResult or {}
					pending = false
					render()
				end)
			end)
		end)
	end)
end

function addDownload(value)
	local uri = noctalia.string.trim(value or link)
	if uri == "" then
		return
	end
	rpc.call("aria2.addUri", { { uri } }, function(_, err)
		message = err or "Download added"
		if not err then
			link = ""
			openCount = openCount + 1
		end
		if opened then
			render()
			refresh()
		end
	end)
end

function setLimit(value)
	local mb = tonumber(noctalia.string.trim(value or limitInput))
	if not mb or mb <= 0 then
		message = "Enter a speed above 0 MB/s"
		render()
		return
	end
	perform("aria2.changeGlobalOption", { { ["max-overall-download-limit"] = tostring(math.floor(mb * 1000000 + 0.5)) } }, "Limit updated")
end

function removeLimit()
	perform("aria2.changeGlobalOption", { { ["max-overall-download-limit"] = "0" } }, "Limit removed")
end

function onOpen()
	opened = true
	openCount = openCount + 1
	link = ""
	limitInput = "7"
	message = ""
	panel.setWantsSecondTicks(true)
	render()
	refresh()
end

function onClose()
	opened = false
end

function update()
	refresh()
end
