require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Add fnm's node to PATH so Mason can find node/npm
-- This is needed because fnm uses shell hooks that don't run in Neovim's environment
local fnm_node_path = vim.fn.expand("~/.local/share/fnm/aliases/default/bin")
if vim.fn.isdirectory(fnm_node_path) == 1 then
  vim.env.PATH = fnm_node_path .. ":" .. vim.env.PATH
end
