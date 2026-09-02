-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Troca rápida entre os repositórios do ambiente multi-repo Deps (~/Documentos/Deps)
local function deps_pick_repo()
  local root = vim.fn.expand("~/Documentos/Deps")
  local entries = vim.fn.readdir(root, [[isdirectory(v:val) && v:val !~ '^\.']])
  table.sort(entries)
  vim.ui.select(entries, { prompt = "Repositório Deps:" }, function(choice)
    if choice then
      vim.cmd("lcd " .. root .. "/" .. choice)
      vim.notify("cwd local -> " .. choice)
    end
  end)
end

vim.keymap.set("n", "<leader>fw", deps_pick_repo, { desc = "Trocar de repositório (Deps)" })
