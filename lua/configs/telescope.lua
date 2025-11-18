local options = {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden", -- Add hidden files support
    },
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist/",
      "build/",
      "target/",
    },
  },
  pickers = {
    find_files = {
      hidden = true, -- Show hidden files
      find_command = {
        "rg",
        "--files",
        "--hidden",
        "--glob",
        "!**/.git/*", -- Exclude .git directory
      },
    },
  },
}

return options

