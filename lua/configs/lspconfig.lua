require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "ts_ls", "prettierd", "prettier", "tailwindcss"}
vim.lsp.enable(servers)

-- Prettier LSP configuration
-- require("lspconfig").prettierd.setup {
--   on_attach = function(client, bufnr)
--     client.server_capabilities.documentFormattingProvider = true
--   end,
-- }

-- Tailwind CSS LSP configuration (using modern vim.lsp.config API)
vim.lsp.config('tailwindcss', {
  filetypes_exclude = { "markdown" },
  filetypes_include = {},
  settings = {
    tailwindCSS = {
      includeLanguages = {
        elixir = "html-eex",
        eelixir = "html-eex", 
        heex = "html-eex",
      },
    },
  },
})


-- read :h vim.lsp.config for changing options of lsp servers