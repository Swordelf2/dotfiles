local M = {}
local endpoint = "http://127.0.0.1:6800/jsonrpc"
local secret, secretError = noctalia.readFile("~/.config/aria2/rpc-secret")

if secret then
	secret = noctalia.string.trim(secret)
end

function M.call(method, args, callback)
	if not secret or secret == "" then
		callback(nil, "Cannot read aria2 RPC secret: " .. (secretError or "file is empty"))
		return
	end

	local params = { "token:" .. secret }
	for _, value in ipairs(args or {}) do
		table.insert(params, value)
	end

	local body, encodeError = noctalia.json.encode({
		jsonrpc = "2.0",
		id = "noctalia-aria2",
		method = method,
		params = params,
	})
	if not body then
		callback(nil, encodeError or "Could not encode RPC request")
		return
	end

	local accepted = noctalia.http({
		url = endpoint,
		method = "POST",
		body = body,
		headers = { "Content-Type: application/json" },
	}, function(response)
		if not response.ok or response.status ~= 200 then
			callback(nil, "aria2 is unavailable")
			return
		end

		local payload, decodeError = noctalia.json.decode(response.body)
		if not payload then
			callback(nil, decodeError or "Invalid aria2 response")
		elseif payload.error then
			callback(nil, payload.error.message or "aria2 rejected the request")
		else
			callback(payload.result, nil)
		end
	end)

	if not accepted then
		callback(nil, "Could not start aria2 request")
	end
end

return M
