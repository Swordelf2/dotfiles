return {
  {
    "folke/tokyonight.nvim",
    -- lazy = false,    -- load on startup
    -- priority = 1000, -- make sure it loads before other plugins
    opts = {
      style = "night", -- "storm", "moon", "night", or "day"
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
}
