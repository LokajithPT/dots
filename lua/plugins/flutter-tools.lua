-- lua/plugins/flutter-tools.lua
-- Flutter / Dart development: dartls LSP, hot reload, devices, outline, formatting.
-- NOTE: do NOT configure `dartls` anywhere else (mason-lspconfig etc.) -- this
-- plugin starts the Dart language server itself.

return {
  "nvim-flutter/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Used for the LSP capabilities below so dartls completions appear in nvim-cmp.
    "hrsh7th/cmp-nvim-lsp",
  },

  config = function()
    -----------------------------------------------------------------
    -- Capabilities: hand dartls the nvim-cmp set so autocomplete works.
    -----------------------------------------------------------------
    local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    local capabilities = cmp_ok and cmp_lsp.default_capabilities()
      or vim.lsp.protocol.make_client_capabilities()

    -----------------------------------------------------------------
    -- Format the current Dart buffer with `dart format`.
    -- Synchronous on purpose so it can run from BufWritePre.
    -----------------------------------------------------------------
    local function format_dart()
      if vim.bo.filetype ~= "dart" then
        return
      end
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "dartls" })) do
        if client:supports_method("textDocument/formatting") then
          vim.lsp.buf.format({ bufnr = 0, id = client.id, timeout_ms = 3000 })
          return
        end
      end
    end

    -----------------------------------------------------------------
    -- Buffer-local keymaps that only make sense in a Dart/Flutter buffer.
    -----------------------------------------------------------------
    local function on_attach(_, bufnr)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- Editing / LSP
      map("n", "<leader>fm", format_dart, "Dart: format buffer")
      map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
      map("n", "gs", "<cmd>FlutterSuper<CR>", "Dart: go to super")

      -- Flutter run / project workflow (capital F to avoid the <leader>f* find maps)
      map("n", "<leader>Fs", "<cmd>FlutterCommands<CR>", "Flutter: command picker")
      map("n", "<leader>Fr", "<cmd>FlutterRun<CR>", "Flutter: run")
      map("n", "<leader>FR", "<cmd>FlutterReload<CR>", "Flutter: hot reload")
      map("n", "<leader>FS", "<cmd>FlutterRestart<CR>", "Flutter: hot restart")
      map("n", "<leader>Fq", "<cmd>FlutterQuit<CR>", "Flutter: quit session")
      map("n", "<leader>Fd", "<cmd>FlutterDevices<CR>", "Flutter: pick device")
      map("n", "<leader>Fe", "<cmd>FlutterEmulators<CR>", "Flutter: pick emulator")
      map("n", "<leader>Fo", "<cmd>FlutterOutlineToggle<CR>", "Flutter: toggle outline")
      map("n", "<leader>Fv", "<cmd>FlutterVisualDebug<CR>", "Flutter: visual debug")
      map("n", "<leader>Fp", "<cmd>FlutterPubGet<CR>", "Flutter: pub get")

      -- Neovim 0.12: render colors reported by dartls inline.
      if vim.lsp.document_color and vim.lsp.document_color.enable then
        pcall(vim.lsp.document_color.enable, true, { bufnr = bufnr })
      end
    end

    -----------------------------------------------------------------
    -- Plugin setup
    -----------------------------------------------------------------
    require("flutter-tools").setup({
      ui = { border = "rounded" },
      fvm = false,

      -- Show the vertical/horizontal guides that line up a widget's closing paren.
      widget_guides = { enabled = true },

      -- Virtual text closing tags: `// Column`, `// Padding`, ...
      closing_tags = {
        enabled = true,
        highlight = "Comment",
        prefix = "// ",
        priority = 10,
      },

      decorations = {
        statusline = {
          app_version = false,
          device = false,
          project_config = false,
        },
      },

      -- Log window for `flutter run` output; don't steal focus when opening.
      dev_log = {
        enabled = true,
        notify_errors = true,
        open_cmd = "15split",
        focus_on_open = false,
      },

      dev_tools = {
        autostart = true,
        auto_open_browser = false,
      },

      outline = {
        open_cmd = "30vnew",
        auto_open = false,
      },

      widget_preview = { web_server = true },

      -- Breakpoint debugging needs nvim-dap + nvim-dap-ui. Turn this on after
      -- installing them; enabling it without nvim-dap breaks :FlutterRun.
      debugger = { enabled = false },

      lsp = {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          enableSnippets = true,
          updateImportsOnRename = true, -- keep imports correct on rename
          renameFilesWithClasses = "prompt", -- "always" to skip the prompt
          lineLength = 100,
        },
      },
    })

    -----------------------------------------------------------------
    -- Format Dart files on save.
    -----------------------------------------------------------------
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.dart",
      group = vim.api.nvim_create_augroup("FlutterFormatOnSave", { clear = true }),
      callback = format_dart,
    })

    -----------------------------------------------------------------
    -- Neovim ships treesitter highlighting for lua/etc. but not for dart.
    -- Turn it on (and use treesitter indentation) for Dart buffers.
    -----------------------------------------------------------------
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dart",
      group = vim.api.nvim_create_augroup("FlutterTreesitter", { clear = true }),
      callback = function()
        if not pcall(vim.treesitter.start) then
          return
        end
        pcall(function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end)
      end,
    })
  end,
}
