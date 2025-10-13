local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier", "prettierd" },
    typescript = { "prettier", "prettierd" },
    javascriptreact = { "prettier", "prettierd" },
    typescriptreact = { "prettier", "prettierd" },
    json = { "prettier", "prettierd" },
    css = { "prettier", "prettierd" },
    scss = { "prettier", "prettierd" },
    less = { "prettier", "prettierd" },
    html = { "prettier", "prettierd" },
    markdown = { "prettier", "prettierd" },
    yaml = { "prettier", "prettierd" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 2500,
    lsp_fallback = true,
  },

  -- -- Prettier configuration - Updated to use prettier.config.js
  formatters = {
    prettier = {
      prepend_args = { "--prose-wrap", "always" },
    },
  },
}

return options
