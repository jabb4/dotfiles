return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "goimports", "gofmt" },
        python = { "ruff_format" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        rust = { "rustfmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
      },
      format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
    },
  },
}
