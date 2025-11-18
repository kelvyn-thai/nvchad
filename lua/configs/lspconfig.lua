require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "ts_ls",
  "prettierd",
  "prettier",
  "tailwindcss",
  "dockerls",
  "docker-language-server",
  "docker-compose-language-service",
  "yaml-language-server",
  "yamlls",
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

vim.lsp.config("docker-compose-language-service", {
  settings = {
    dockerCompose = {
      languageServer = {
        formatter = {
          ignoreMultilineInstructions = true,
        },
      },
    },
  },
})

-- YAML LSP configuration
vim.lsp.config("yamlls", {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = {
    "yaml",
    "yml",
    "yaml.docker-compose",
    "yaml.gitlab",
  },
  root_dir = function(bufnr, on_dir)
    -- Find project root by walking up from the file's directory
    -- This ensures LSP works for files in subdirectories like templates/
    local file_path = vim.api.nvim_buf_get_name(bufnr)
    local project_root = nil
    
    if file_path and file_path ~= "" then
      local dir = vim.fs.dirname(file_path)
      local current = dir
      
      -- Walk up directory tree to find .git or .gitlab-ci.yml
      while current and current ~= "/" do
        local git_dir = current .. "/.git"
        local gitlab_ci = current .. "/.gitlab-ci.yml"
        
        -- Check for .git directory (can be file or directory)
        if vim.fn.isdirectory(git_dir) == 1 or vim.fn.filereadable(git_dir) == 1 then
          project_root = current
          break
        end
        
        -- Also check for .gitlab-ci.yml as a marker
        if vim.fn.filereadable(gitlab_ci) == 1 then
          project_root = current
          break
        end
        
        -- Move to parent directory
        local parent = vim.fs.dirname(current)
        if parent == current then
          break
        end
        current = parent
      end
    end
    
    -- Fallback: use vim.fs.root with .git marker
    if not project_root then
      project_root = vim.fs.root(bufnr, { ".git" })
    end
    
    -- Final fallback to current working directory
    on_dir(project_root or vim.fn.getcwd())
  end,
  settings = {
    yaml = {
      format = {
        enable = true,
      },
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      schemas = {
        kubernetes = "k8s-*.yaml",
        ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
        ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
        ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/**/*.{yml,yaml}",
        ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
        ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
        ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
        ["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
        -- Docker Compose schema - explicitly map to docker-compose files
        ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
          "docker-compose*.{yml,yaml}",
          "compose*.{yml,yaml}",
        },
      },
      completion = true,
      hover = true,
      validate = true,
    },
    -- Disable telemetry
    redhat = { telemetry = { enabled = false } },
  },
})

-- read :h vim.lsp.config for changing options of lsp servers
