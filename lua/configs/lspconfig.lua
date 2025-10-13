require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "ts_ls",
  "prettierd",
  "prettier",
  "tailwindcss",
  "dockerls",
  "docker_language_server",
  "docker_compose_language_service",
}
vim.lsp.enable(servers)

-- Prettier LSP configuration
-- require("lspconfig").prettierd.setup {
--   on_attach = function(client, bufnr)
--     client.server_capabilities.documentFormattingProvider = true
--   end,
-- }

-- Tailwind CSS LSP configuration (using modern vim.lsp.config API)
vim.lsp.config("tailwindcss", {
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

vim.lsp.config("dockerls", {
  settings = {
    docker = {
      languageserver = {
        formatter = {
          ignoreMultilineInstructions = true,
        },
      },
    },
  },
})

-- read :h vim.lsp.config for changing options of lsp servers
