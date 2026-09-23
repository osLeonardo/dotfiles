return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "netcoredbg" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      if not dap.adapters["netcoredbg"] then
        local netcoredbg = vim.fn.exepath("netcoredbg")
        if netcoredbg == "" then
          netcoredbg = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
        end
        dap.adapters["netcoredbg"] = {
          type = "executable",
          command = netcoredbg,
          args = { "--interpreter=vscode" },
        }
      end
      for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
        if not dap.configurations[lang] then
          dap.configurations[lang] = {
            {
              type = "netcoredbg",
              name = "Launch file",
              request = "launch",
              program = function()
                return vim.fn.input("Caminho da dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
              end,
              cwd = "${workspaceFolder}",
            },
          }
        end
      end
    end,
  },
}
