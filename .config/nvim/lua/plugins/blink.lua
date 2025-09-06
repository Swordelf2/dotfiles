return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<C-t>"] = { "show" },
        ["<CR>"] = { "fallback" }, -- fallback means: do normal <CR> (newline)
        ["<Tab>"] = { "accept", "fallback" }, -- accept completion if visible, else fallback
      },
    },
  },
}
