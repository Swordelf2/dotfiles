-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "q", "<cmd>quit<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Write" })

local function copy_file_location()
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		vim.notify("Current buffer has no file path", vim.log.levels.WARN)
		return
	end

	local location = string.format("%s:%d:%d", filepath, vim.fn.line("."), vim.fn.col("."))
	vim.fn.setreg("+", location, "c")
	vim.notify("Copied: " .. location)
end

vim.keymap.set("n", "<leader>fy", copy_file_location, { desc = "Copy File Location" })
