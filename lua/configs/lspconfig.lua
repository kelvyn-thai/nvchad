local nvchad_lsp = require("nvchad.configs.lspconfig")
local default_config = nvchad_lsp.defaults()
local default_on_attach = default_config and default_config.on_attach or nil

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
  "eslint_d",
  "eslint",
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

local util = require 'lspconfig.util'
local lsp = vim.lsp

local eslint_config_files = {
  '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.yaml',
  '.eslintrc.yml',
  '.eslintrc.json',
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.cjs',
  'eslint.config.ts',
  'eslint.config.mts',
  'eslint.config.cts',
}

---@type vim.lsp.Config
vim.lsp.config("eslint", {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
    'svelte',
    'astro',
    'htmlangular',
  },
  workspace_required = false,
  on_attach = function(client, bufnr)
    -- Call default on_attach if available
    if default_on_attach then
      default_on_attach(client, bufnr)
    end

    -- Create LspEslintFixAll command
    vim.api.nvim_buf_create_user_command(bufnr, 'LspEslintFixAll', function()
      client:request_sync('workspace/executeCommand', {
        command = 'eslint.applyAllFixes',
        arguments = {
          {
            uri = vim.uri_from_bufnr(bufnr),
            version = lsp.util.buf_versions[bufnr],
          },
        },
      }, nil, bufnr)
    end, {})

    -- Auto-fix on save (optional - uncomment if desired)
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   buffer = bufnr,
    --   command = "LspEslintFixAll",
    -- })
  end,
  root_dir = function(bufnr, on_dir)
    -- The project root is where the LSP can be started from
    -- As stated in the documentation above, this LSP supports monorepos and simple projects.
    -- We select then from the project root, which is identified by the presence of a package
    -- manager lock file.
    local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
    -- Give the root markers equal priority by wrapping them in a table
    root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers, { '.git' } }
      or vim.list_extend(root_markers, { '.git' })

    -- exclude deno
    if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' }) then
      return
    end

    -- We fallback to the current working directory if no project root is found
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

    -- We know that the buffer is using ESLint if it has a config file
    -- in its directory tree.
    --
    -- Eslint used to support package.json files as config files, but it doesn't anymore.
    -- We keep this for backward compatibility.
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if not filename or filename == "" then
      on_dir(project_root)
      return
    end

    local eslint_config_files_with_package_json =
      util.insert_package_json(eslint_config_files, 'eslintConfig', filename)
    
    -- Search for ESLint config from the file's directory up to the project root
    -- Use project_root as the stop point (inclusive), not its parent
    local is_buffer_using_eslint = vim.fs.find(eslint_config_files_with_package_json, {
      path = vim.fs.dirname(filename),
      type = 'file',
      limit = 1,
      upward = true,
      stop = project_root,
    })[1]
    
    -- Also check directly in project root
    if not is_buffer_using_eslint then
      for _, config_file in ipairs(eslint_config_files_with_package_json) do
        local config_path = project_root .. '/' .. config_file
        if vim.fn.filereadable(config_path) == 1 then
          is_buffer_using_eslint = config_path
          break
        end
      end
    end

    -- If no config found, still try to start (ESLint might use default config or package.json)
    -- This allows ESLint to work even if config detection fails
    on_dir(project_root)
  end,
  -- Refer to https://github.com/Microsoft/vscode-eslint#settings-options for documentation.
  settings = {
    validate = 'on',
    ---@diagnostic disable-next-line: assign-type-mismatch
    packageManager = nil,
    useESLintClass = false,
    experimental = {
      useFlatConfig = false,
    },
    codeActionOnSave = {
      enable = false,
      mode = 'all',
    },
    format = true,
    quiet = false,
    onIgnoredFiles = 'off',
    rulesCustomizations = {},
    run = 'onType',
    problems = {
      shortenToSingleLine = false,
    },
    -- nodePath configures the directory in which the eslint server should start its node_modules resolution.
    -- This path is relative to the workspace folder (root dir) of the server instance.
    nodePath = '',
    -- use the workspace folder location or the file location (if no workspace folder is open) as the working directory
    workingDirectory = { mode = 'auto' },
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = 'separateLine',
      },
      showDocumentation = {
        enable = true,
      },
    },
  },
  before_init = function(_, config)
    -- The "workspaceFolder" is a VSCode concept. It limits how far the
    -- server will traverse the file system when locating the ESLint config
    -- file (e.g., .eslintrc).
    local root_dir = config.root_dir

    if root_dir then
      config.settings = config.settings or {}
      config.settings.workspaceFolder = {
        uri = vim.uri_from_fname(root_dir),
        name = vim.fn.fnamemodify(root_dir, ':t'),
      }

      -- Support flat config files
      -- They contain 'config' in the file name
      local flat_config_files = vim.tbl_filter(function(file)
        return file:match('config')
      end, eslint_config_files)

      for _, file in ipairs(flat_config_files) do
        local found_files = vim.fn.globpath(root_dir, file, true, true)

        -- Filter out files inside node_modules
        local filtered_files = {}
        for _, found_file in ipairs(found_files) do
          if string.find(found_file, '[/\\]node_modules[/\\]') == nil then
            table.insert(filtered_files, found_file)
          end
        end

        if #filtered_files > 0 then
          config.settings.experimental = config.settings.experimental or {}
          config.settings.experimental.useFlatConfig = true
          break
        end
      end

      -- Support Yarn2 (PnP) projects
      local pnp_cjs = root_dir .. '/.pnp.cjs'
      local pnp_js = root_dir .. '/.pnp.js'
      if type(config.cmd) == 'table' and (vim.uv.fs_stat(pnp_cjs) or vim.uv.fs_stat(pnp_js)) then
        config.cmd = vim.list_extend({ 'yarn', 'exec' }, config.cmd --[[@as table]])
      end
    end
  end,
  handlers = {
    ['eslint/openDoc'] = function(_, result)
      if result then
        vim.ui.open(result.url)
      end
      return {}
    end,
    ['eslint/confirmESLintExecution'] = function(_, result)
      if not result then
        return
      end
      return 4 -- approved
    end,
    ['eslint/probeFailed'] = function()
      vim.notify('[lspconfig] ESLint probe failed.', vim.log.levels.WARN)
      return {}
    end,
    ['eslint/noLibrary'] = function()
      vim.notify('[lspconfig] Unable to find ESLint library.', vim.log.levels.WARN)
      return {}
    end,
  },
})

-- read :h vim.lsp.config for changing options of lsp servers
