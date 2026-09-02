return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "netcoredbg" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      if not dap.adapters["netcoredbg"] then
        dap.adapters["netcoredbg"] = {
          type = "executable",
          command = vim.fn.exepath("netcoredbg"),
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
