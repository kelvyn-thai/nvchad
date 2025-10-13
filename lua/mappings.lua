require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- nvim-spectre mappings
map("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', { desc = "Toggle Spectre" })
map(
  "n",
  "<leader>sw",
  '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
  { desc = "Search current word" }
)
map("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "Search current word" })
map(
  "n",
  "<leader>sp",
  '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
  { desc = "Search on current file" }
)

-- vim-surround custom mappings
map("n", "ga", 'cs', { desc = "Change surround" })
map("n", "gA", 'cS', { desc = "Change surround line" })
map("v", "ga", 'S', { desc = "Surround selection" })
map("v", "gA", 'gS', { desc = "Surround selection line" })

-- Diagnostic toggle mappings (Enhanced with tiny-inline-diagnostic)
local function toggle_diagnostics()
  -- Try to use tiny-inline-diagnostic toggle if available
  local ok, tiny_diag = pcall(require, 'tiny-inline-diagnostic')
  
  if ok then
    tiny_diag.toggle()
    local config = vim.diagnostic.config()
    local enabled = config.virtual_text or (config.signs and config.underline)
    print("Diagnostics " .. (enabled and "enabled" or "disabled"))
  else
    -- Fallback to standard diagnostic toggle
    local config = vim.diagnostic.config()
    local enabled = config.virtual_text and config.signs and config.underline
    
    if enabled then
      vim.diagnostic.config({
        virtual_text = false,
        signs = false,
        underline = false,
        update_in_insert = false,
        severity_sort = false,
      })
      print("Diagnostics disabled")
    else
      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
      print("Diagnostics enabled")
    end
  end
end

-- Custom diagnostic mappings
map("n", "<leader>td", toggle_diagnostics, { desc = "Toggle diagnostics" })
map("n", "<leader>te", function() vim.diagnostic.open_float() end, { desc = "Show diagnostic float" })
map("n", "<leader>t[", function() vim.diagnostic.goto_prev() end, { desc = "Previous diagnostic" })
map("n", "<leader>t]", function() vim.diagnostic.goto_next() end, { desc = "Next diagnostic" })

-- Also try the LazyVim default keybinding
map("n", "<leader>ud", toggle_diagnostics, { desc = "Toggle diagnostics (LazyVim style)" })
