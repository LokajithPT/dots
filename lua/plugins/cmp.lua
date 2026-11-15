-- lua/plugins/cmp.lua
-- Completionplugin configuration using nvim-cmp + luaSnip + LSP source

return {
  -- Main completion engine
  "hrsh7th/nvim-cmp",

  -- Load other sources on demand
  dependencies = {
    "hrsh7th/cmp-buffer",  -- buffer words
    "hrsh7th/cmp-path",    -- file system paths
    "hrsh7th/cmp-nvim-lsp",-- LSP completions
    "hrsh7th/cmp-cmdline", -- cmdline completions
    "L3MON4D3/LuaSnip",    -- snippet engine
    "saadparwaiz1/cmp_luasnip", -- snippet source for cmp
  },

  -- Run the actual setup once all deps are loaded
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    cmp.setup({
      -- Tell the snippet engine how to expand snippet nodes
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body) -- for friendly snippets
        end,
      },

      -- Key mappings in insert mode
      mapping = cmp.mapping.preset.insert({
        -- Navigation
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        -- Scroll documentation
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        -- Trigger completion menu
        ['<C-Space>'] = cmp.mapping.complete(),
        -- Accept currently selected item
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        -- Exit completion without accepting
        ['<C-e>'] = cmp.mapping.abort(),
      }),

      -- Where to get completions from
      sources = cmp.config.sources({
        { name = 'nvim_lsp' }, -- LSP source (auto‑completion from active servers)
        { name = 'luasnip' },  -- snippet completions
      }, {
        { name = 'buffer' },   -- completions from current buffer
        { name = 'path' },     -- completions from file system
      }),

      -- Enable LSP diagnostics as a source (shows errors/warnings as you type)
      enabled = function()
        -- You can disable completion in certain filetypes if you want
        return true
      end,
    })

    -- Cmdline completion: / searches from buffer, : commands via cmp-cmdline
    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = 'buffer' } }),
    })
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      -- path: file completion; cmdline: actual :commands (from cmp-cmdline).
      -- NOTE: the key must be `sources` (plural) — the old `source` key was
      -- silently ignored, so :command completion never worked.
      sources = cmp.config.sources(
        { { name = 'path' } },
        { { name = 'cmdline' } }
      ),
    })

    -- nvim-autopairs: close/expand pairs when a completion is confirmed
    local ap_ok, ap_cmp = pcall(require, "nvim-autopairs.completion.cmp")
    if ap_ok then
      cmp.event:on('confirm_done', ap_cmp.on_confirm_done())
    end
  end,
}