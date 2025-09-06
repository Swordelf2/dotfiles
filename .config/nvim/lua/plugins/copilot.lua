return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      -- panel = {
      --   enabled = false, -- change this
      --   auto_refresh = true,
      --   keymap = {
      --     jump_prev = "[[",
      --     jump_next = "]]",
      --     accept = "<CR>",
      --     refresh = "gr",
      --     open = "<A-CR>", -- Alt+Enter to open panel
      --   },
      --   layout = {
      --     position = "bottom", -- or top, left, right
      --     ratio = 0.4,
      --   },
      -- },
      filetypes = {
        markdown = false,
        help = false,
        text = false,
        ["*.rs"] = true,
      },
    },
  },
}
