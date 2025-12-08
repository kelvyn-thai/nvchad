local lint = require("lint")


vim.env.ESLINT_D_PPID = vim.fn.getpid()

lint.linters_by_ft = {
  yaml = { "yamllint" },
  yml = { "yamllint" },
  javascript = {'eslint_d'},
  typescript = {'eslint_d'},
}

-- Configure yamllint parser
lint.linters.yamllint = {
  cmd = "yamllint",
  args = { "--format", "parsable" },
  stdin = false,
  stream = "stdout",
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local diagnostics = {}
    if not output or output == "" then
      return diagnostics
    end
    
    local lines = vim.split(output, "\n")
    
    for _, line in ipairs(lines) do
      if line ~= "" then
        -- yamllint parsable format: file:line:col: [error|warning] message (rule)
        -- Example: stdin:5:9: [warning] too few spaces before comment: expected 2 (comments)
        -- Try matching with brackets first
        local file, line_num, col, severity, message = line:match("([^:]+):(%d+):(%d+):%s*%[([^%]]+)%]%s*(.+)")
        
        -- If that doesn't match, try without brackets (some formats)
        if not file then
          file, line_num, col, severity, message = line:match("([^:]+):(%d+):(%d+):%s*([^:]+):%s*(.+)")
        end
        
        if file and line_num and col then
          local severity_map = {
            error = vim.diagnostic.severity.ERROR,
            warning = vim.diagnostic.severity.WARN,
            info = vim.diagnostic.severity.INFO,
          }
          
          -- Normalize severity (case insensitive)
          severity = severity:lower()
          if severity:match("error") then
            severity = "error"
          elseif severity:match("warning") or severity:match("warn") then
            severity = "warning"
          else
            severity = "warning" -- Default to warning
          end
          
          table.insert(diagnostics, {
            lnum = tonumber(line_num) - 1, -- Convert to 0-based
            col = tonumber(col) - 1, -- Convert to 0-based
            end_lnum = tonumber(line_num) - 1,
            end_col = tonumber(col),
            severity = severity_map[severity] or vim.diagnostic.severity.WARN,
            message = message or line,
            source = "yamllint",
          })
        end
      end
    end
    
    return diagnostics
  end,
}

-- Auto-run linters on save and when opening files
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    lint.try_lint()
  end,
})

return lint
