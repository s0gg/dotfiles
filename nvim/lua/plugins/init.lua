return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          which_key = true,
          native_lsp = {
            enabled = true
          },
          treesitter = true,
          telescope = {
            enabled = true
          }
        },
      })
      vim.cmd.colorscheme "catppuccin"
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin"
        }
      })
    end
  },
  {
    "lambdalisue/gin.vim",
    event = "VeryLazy",
    config = function()
      vim.keymap.set("n", "<space>gi", "<cmd>GinStatus<CR>", { silent = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'gin-status',
        callback = function()
          vim.keymap.set('n', 'rr', '<Plug>(gin-action-restore)', { silent = true })
        end
      })
    end
  },
  {
    "stevearc/oil.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup()
      vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })()
    end,
    config = function()
      local config = require("nvim-treesitter.configs")

      config.setup({
        ensure_installed = { "lua" },
        sync_install = false,
        highlight = { enable = true },
        incremental_selection = { enable = true },
        textobjects = { enable = true },
        autotag = { enable = true }
      })

      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
    end
  },
  { "folke/neodev.nvim" },
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPost",
    dependencies = {
      "folke/neodev.nvim",
      "hrsh7th/cmp-nvim-lsp"
    },
    config = function()
      require("neodev").setup({})

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }
            },
            completion = {
              callSnippet = "Replace",
            }
          }
        }
      })
      lspconfig.ruby_lsp.setup({
        capabilities = capabilities
      })
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities
      })
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        root_dir = lspconfig.util.root_pattern("package.json"),
        single_file_support = false
      })
      lspconfig.clangd.setup({
        init_options = {
          fallbackFlags = { "-std=c++20" }
        },
        capabilities = capabilities
      })
      lspconfig.denols.setup({
        capabilities = capabilities,
        root_dir = lspconfig.util.root_pattern("deno.json"),
        init_options = {
          list = true,
          unstable = true,
          suggest = {
            imports = {
              hosts = {
                ["https://deno.land"] = true,
                ["https://cdn.nest.land"] = true,
                ["https://crux.land"] = true,
                ['https://esm.sh'] = true
              }
            }
          }
        }
      })

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>lf', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
    end
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("gitsigns").setup({
        on_attach = function()
          vim.keymap.set("n", "<space>hs", function() require("gitsigns").stage_hunk() end, { silent = true })
          vim.keymap.set("n", "<space>hr", function() require("gitsigns").reset_hunk() end, { silent = true })
          vim.keymap.set("n", "<space>hp", function() require("gitsigns").preview_hunk() end, { silent = true })
          vim.keymap.set("n", "]c", function() require("gitsigns").next_hunk() end, { silent = true })
          vim.keymap.set("n", "[c", function() require("gitsigns").previous_hunk() end, { silent = true })
        end
      })
    end
  },
  { "L3MON4D3/LuaSnip" },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip"
    },
    config = function()
      -- Set up nvim-cmp.
      local cmp = require 'cmp'

      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          -- { name = 'vsnip' }, -- For vsnip users.
          { name = 'luasnip' }, -- For luasnip users.
          -- { name = 'ultisnips' }, -- For ultisnips users.
          -- { name = 'snippy' }, -- For snippy users.
        }, {
          { name = 'buffer' },
        })
      })

      -- Set configuration for specific filetype.
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
        }, {
          { name = 'buffer' },
        })
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end
  },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    init = function()
      vim.g.startuptime_tries = 10
    end
  },
  {
    "vim-denops/denops.vim"
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end
  },
  {
    "hrsh7th/nvim-insx",
    event = "InsertEnter",
    config = function()
      require("insx.preset.standard").setup()
    end
  },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- require("telescope_rc")
      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<Space>ff', builtin.find_files, {})
      vim.keymap.set('n', '<Space>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<Space>fb', builtin.buffers, {})
      vim.keymap.set('n', '<Space>fh', builtin.help_tags, {})
    end
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
    end
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      vim.keymap.set("n", "<space>xx", function() require("trouble").toggle() end)
    end
  },
  {
    'kylechui/nvim-surround',
    config = function()
      require("nvim-surround").setup()
    end
  },
  {
    'smoka7/hop.nvim',
    version = '*',
    event = 'VeryLazy',
    config = function()
      require('hop').setup()
      vim.keymap.set('n', '<space>s', require('hop').hint_char1, { silent = true })
    end
  },
  {
    'lambdalisue/kensaku.vim',
    event = 'VeryLazy',
    dependencies = { 'vim-denops/denops.vim' }
  },
  {
    'lambdalisue/kensaku-search.vim',
    event = 'VeryLazy',
    require = 'lambdalisue/kensaku.vim',
    config = function()
      vim.keymap.set('c', '<CR>', '<Plug>(kensaku-search-replace)<cr>')
    end
  },
  {
    'shellRaining/hlchunk.nvim',
    event = 'UIEnter',
    config = function()
      require('hlchunk').setup({})
    end
  },
  {
    'stevearc/overseer.nvim',
    event = 'VeryLazy'
  },
  {
    'monaqa/dial.nvim',
    event = 'VeryLazy'
  },
  {
    'j-hui/fidget.nvim',
    lazy = false,
    config = function()
      require('fidget').setup()
    end
  },
  {
    'stevearc/aerial.nvim',
    opts = {},
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('aerial').setup()
    end
  },
  {
    'stevearc/conform.nvim',
    event = 'VeryLazy',
    opts = {},
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          javascript = { 'biome' },
          lua = { 'stylua' },
          python = { 'black' },
          rust = { 'rustfmt' },
          ruby = { 'rufo' },
          typescript = { 'biome' },
          typescriptreact = { 'biome' },
        }
      })
      vim.keymap.set('v', '<space>ff', function()
        require('conform').format({ async = true, lsp_fallback = true })
      end)
      vim.keymap.set('n', '<space>cf', function()
        require('conform').format({ async = true, lsp_fallback = true })
      end)
    end
  },
  {
    'tani/dmacro.nvim',
    config = function()
      require('dmacro').setup({
        dmacro_key = '<C-t>'
      })
    end
  }
}
