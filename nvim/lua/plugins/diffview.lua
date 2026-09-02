return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: abrir (resolver conflitos)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: histórico do arquivo" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: fechar" },
    },
  },
}
