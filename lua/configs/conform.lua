local function has_biome_config(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == nil or filename == "" then
    return false
  end

  local found = vim.fs.find({ "biome.json", "biome.jsonc" }, {
    path = vim.fs.dirname(filename),
    upward = true,
    type = "file",
    limit = 1,
  })[1]

  return found ~= nil
end

local function web_formatters(bufnr)
  if has_biome_config(bufnr) then
    return { "biome" }
  end

  return { "prettier", "prettierd" }
end

local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = web_formatters,
    typescript = web_formatters,
    javascriptreact = web_formatters,
    typescriptreact = web_formatters,
    json = web_formatters,
    css = web_formatters,
    scss = web_formatters,
    less = web_formatters,
    html = web_formatters,
    markdown = web_formatters,
    yaml = web_formatters,
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
