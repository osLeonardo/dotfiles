return {
  {
    "folke/edgy.nvim",
    opts = {
      left = {
        {
          title = "Explorer",
          ft = "neo-tree",
          filter = function(_, win)
            return vim.w[win].neo_tree_source == "filesystem"
          end,
          size = { width = 30 },
        },
      },
      bottom = {
        { ft = "toggleterm", size = { height = 12 } },
        { ft = "qf", title = "QuickFix" },
        { ft = "trouble", title = "Diagnostics" },
      },
    },
  },
}
