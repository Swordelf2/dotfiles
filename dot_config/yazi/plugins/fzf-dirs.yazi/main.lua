--- @since 26.8.15

local M = {}

local cwd = ya.sync(function()
	return cx.active.current.cwd
end)

local function fd_args(dir)
	local args = { "--type", "d", "--hidden", "--no-ignore", "--exclude", ".git", "--exclude", "node_modules" }
	local home = os.getenv("HOME")
	if not home then
		return args
	end

	for _, name in ipairs({ ".local", ".cache" }) do
		local target = Url(home):join(name)
		if target ~= dir and target:starts_with(dir) then
			args[#args + 1] = "--exclude"
			args[#args + 1] = "/" .. tostring(target:strip_prefix(dir))
		end
	end
	return args
end

function M:entry()
	local permit = ui.hide()
	local output, err = M.run_with(cwd())
	permit:drop()
	if not output then
		return ya.notify({ title = "Fzf", content = tostring(err), timeout = 5, level = "error" })
	end

	local urls = M.split_urls(cwd(), output)
	if #urls == 0 then
		return
	elseif #urls == 1 then
		return ya.emit("cd", { urls[1], raw = true })
	end

	local files = {}
	for _, url in ipairs(urls) do
		files[#files + 1] = fs.file(url)
	end
	if #files > 0 then
		files.state = "on"
		ya.emit("toggle_all", files)
	end
end

function M.run_with(dir)
	local source, err = Command("fd")
		:arg(fd_args(dir))
		:cwd(tostring(dir))
		:stdout(Command.PIPED)
		:spawn()
	if not source then
		return nil, Err("Failed to start `fd`, error: %s", err)
	end

	local child, err = Command("fzf")
		:arg("-m")
		:cwd(tostring(dir))
		:stdin(source:take_stdout())
		:stdout(Command.PIPED)
		:spawn()
	if not child then
		source:start_kill()
		source:wait()
		return nil, Err("Failed to start `fzf`, error: %s", err)
	end

	local output, err = child:wait_with_output()
	source:wait()
	if not output then
		return nil, Err("Cannot read `fzf` output, error: %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, Err("`fzf` exited with error code %s", output.status.code)
	end
	return output.stdout, nil
end

function M.split_urls(dir, output)
	local urls = {}
	for line in output:gmatch("[^\r\n]+") do
		local url = Url(line)
		urls[#urls + 1] = url.is_absolute and url or dir:resolve(url)
	end
	return urls
end

return M
