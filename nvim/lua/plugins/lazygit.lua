return {
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
      { "<leader>gG", "<cmd>LazyGitConfig<cr>", desc = "Open LazyGit Config" },
    },
    config = function()
      vim.g.lazygit_floating_window_use_plenary = 1
    end,
  },
}
