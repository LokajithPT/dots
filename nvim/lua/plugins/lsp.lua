-- lua/plugins/lsp.lua
-- This file is loaded by lazy.nvim as a plugin spec.
-- It must return a table describing the plugin and its configuration.

return {
  -- The actual LSP client
  "neovim/nvim-lspconfig",

  -- Mason handles LSP server installation
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },

  -- The function that lazy.nvim will call after the plugin is installed
  config = function()
    -----------------------------------------------------------------
    -- Helper: register a server with the native vim.lsp.config API
    -----------------------------------------------------------------
    local function register_server(name, cfg)
      cfg = cfg or {}
      vim.lsp.config.setup(name, {
        cmd = cfg.cmd,
        settings = cfg.settings,
        init_options = cfg.init_options,
        flags = cfg.flags,
        capabilities = cfg.capabilities or vim.lsp.protocol.make_client_capabilities(),
        on_attach = cfg.on_attach,
      })
    end

    -----------------------------------------------------------------
    -- Mason – ensure the required LSP servers are installed
    -----------------------------------------------------------------
    require("mason").setup()
    local mason_lspconfig = require("mason-lspconfig")

    mason_lspconfig.setup({
      ensure_installed = { "lua_ls", "rust_analyzer" },

      handlers = {
        -- Handler for every server not explicitly overridden
        function(server_name)
          if server_name == "rust_analyzer" then
            -- ====================== Rust Analyzer (with clippy) ======================
            register_server("rust_analyzer", {
              settings = {
                ["rust-analyzer"] = {
                  -- Lower memory: don't analyze all feature combos
                  cargo = {
                    allFeatures = false,
                    -- Skip build scripts and generated OUT_DIR artifacts (big memory savers)
                    loadOutDirsFromCheck = false,
                    buildScripts = { enable = false },
                  },
                  -- Proc-macro expansion is expensive in memory; disable if not needed
                  procMacro = { enable = false },
                  checkOnSave = { command = "clippy" },   -- run clippy on save
                  files = {
                    exclude = {
                      "**/target/**",
                      "**/.git/**",
                      "**/node_modules/**",
                    },
                  },
                  diagnostics = { enable = true, experimental = { enable = false } },
                  -- Smaller query cache (lower memory, slightly slower)
                  lru = { capacity = 1024 },
                },
              },
            })
          else
            -- ====================== Default handler for other servers ======================
            register_server(server_name, {})
          end
        end,

        -- Explicit handler for lua_ls (keeps config tidy)
        ["lua_ls"] = function()
          register_server("lua_ls", {
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
              },
            },
          })
        end,
      },
    })

    -----------------------------------------------------------------
    -- Keymaps (including a “gd” that opens the definition in a split)
    -----------------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(event)
        local opts = { buffer = event.buf }

        -- Open the definition in a vertical split (no floating preview)
        vim.keymap.set("n", "gd", function()
          vim.lsp.buf.definition({ selection = "split" })
        end, opts)

        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

        -- Open document symbols in a Telescope window instead of the bottom quickfix pane
        vim.keymap.set("n", "gO", function()
          require("telescope.builtin").lsp_document_symbols()
        end, { buffer = event.buf, desc = "Document symbols (Telescope)" })
      end,
    })

    -----------------------------------------------------------------
    -- Diagnostics – same configuration you used before
    -----------------------------------------------------------------
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
    })
  end,
}