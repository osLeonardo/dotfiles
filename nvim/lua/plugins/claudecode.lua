return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {},
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude Code: abrir/focar" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude Code: enviar seleção" },
    },
  },
}
