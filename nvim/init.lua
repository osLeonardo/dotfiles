-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- disable tmux status bar on LazyVim startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.env.TMUX then
      os.execute("tmux set status off")
    end
  end,
})

-- enable tmux status bar on LazyVim close
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    if vim.env.TMUX then
      os.execute("tmux set status on")
    end
  end,
})
