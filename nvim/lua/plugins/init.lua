return {
	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "latte",
				transparent_background = true,
				auto_integrations = true,
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin",
				},
			})
		end,
	},
	{
		"lambdalisue/gin.vim",
		event = "VeryLazy",
		config = function()
			vim.keymap.set("n", "<space>gs", "<cmd>GinStatus<CR>", { silent = true })
			vim.keymap.set("n", "<space>gl", "<cmd>GinLog<CR>", { silent = true })
			vim.keymap.set("n", "<space>gc", "<cmd>GinChaperon<CR>", { silent = true })
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "gin-status",
				callback = function()
					vim.keymap.set("n", "rr", "<Plug>(gin-action-restore)", { silent = true, buffer = true })
					vim.keymap.set("n", "cc", "<cmd>Gin commit<cr>", { silent = true, buffer = true })
				end,
			})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "gin-log",
				callback = function()
					vim.keymap.set(
						"n",
						"if",
						"<Plug>(gin-action-fixup:instant-fixup)",
						{ silent = true, buffer = true }
					)
					vim.keymap.set(
						"n",
						"ir",
						"<Plug>(gin-action-fixup:instant-reword)",
						{ silent = true, buffer = true }
					)
				end,
			})
		end,
	},
	{
		"stevearc/oil.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup()
			vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				"lazy.nvim",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPost",
		dependencies = {
			"folke/neodev.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local lspconfig = vim.lsp
			local function add_ruby_deps_command(client, bufnr)
				vim.api.nvim_buf_create_user_command(bufnr, "ShowRubyDeps", function(opts)
					local params = vim.lsp.util.make_text_document_params()
					local showAll = opts.args == "all"

					client.request("rubyLsp/workspace/dependencies", params, function(error, result)
						if error then
							print("Error showing deps: " .. error)
							return
						end

						local qf_list = {}
						for _, item in ipairs(result) do
							if showAll or item.dependency then
								table.insert(qf_list, {
									text = string.format("%s (%s) - %s", item.name, item.version, item.dependency),
									filename = item.path,
								})
							end
						end

						vim.fn.setqflist(qf_list)
						vim.cmd("copen")
					end, bufnr)
				end, {
					nargs = "?",
					complete = function()
						return { "all" }
					end,
				})
			end

			lspconfig.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			})
			lspconfig.config("rust_analyzer", {
				capabilities = capabilities,
			})
			lspconfig.config("prismals", {
				filetypes = { "prisma" },
				capabilities = capabilities,
			})
			lspconfig.config("ts_ls", {
				capabilities = capabilities,
				single_file_support = false,
			})
			lspconfig.config("vtsls", {
				capabilities = capabilities,
			})

			-- vim.api.nvim_create_autocmd('BufReadPost', {
			--   desc = "LSP: iccheck",
			--   callback = function()
			--     vim.lsp.start({
			--       capabilities = capabilities,
			--       cmd = { vim.env.HOME .. '/.nix-profile/bin/iccheck', 'lsp' },
			--       name = 'iccheck',
			--       root_dir = vim.fn.getcwd()
			--     })
			--   end
			-- })

			vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
			vim.keymap.set("n", "[d", vim.diagnostic.get_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.get_next)
			vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set("n", "<space>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, opts)
					vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "<space>lf", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
				end,
			})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup({
				on_attach = function()
					vim.keymap.set("n", "<space>hs", function()
						require("gitsigns").stage_hunk()
					end, { silent = true })
					vim.keymap.set("n", "<space>hr", function()
						require("gitsigns").reset_hunk()
					end, { silent = true })
					vim.keymap.set("n", "<space>hp", function()
						require("gitsigns").preview_hunk()
					end, { silent = true })
					vim.keymap.set("n", "]c", function()
						require("gitsigns").nav_hunk("next")
					end, { silent = true })
					vim.keymap.set("n", "[c", function()
						require("gitsigns").nav_hunk("prev")
					end, { silent = true })
				end,
			})
		end,
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
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			-- Set up nvim-cmp.
			local cmp = require("cmp")

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
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "lazydev", group_index = 0 },
					{ name = "nvim_lsp" },
					-- { name = 'vsnip' }, -- For vsnip users.
					{ name = "luasnip" }, -- For luasnip users.
					-- { name = 'ultisnips' }, -- For ultisnips users.
					-- { name = 'snippy' }, -- For snippy users.
				}, {
					{ name = "buffer" },
				}),
			})

			-- Set configuration for specific filetype.
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({
					{ name = "git" }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
				}, {
					{ name = "buffer" },
				}),
			})

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},
	{
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		init = function()
			vim.g.startuptime_tries = 10
		end,
	},
	{
		"vim-denops/denops.vim",
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
	},
	{ "nvim-lua/plenary.nvim" },
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup()
		end,
	},
	{
		"smoka7/hop.nvim",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("hop").setup()
			vim.keymap.set("n", "<space>s", require("hop").hint_char1, { silent = true })
		end,
	},
	{
		"shellRaining/hlchunk.nvim",
		event = "UIEnter",
		config = function()
			require("hlchunk").setup({})
		end,
	},
	{
		"stevearc/overseer.nvim",
		event = "VeryLazy",
	},
	{
		"j-hui/fidget.nvim",
		lazy = false,
		opts = {},
	},
	{
		"thinca/vim-qfreplace",
		event = "VeryLazy",
	},
	{
		"stevearc/quicker.nvim",
		event = "FileType qf",
		---@module "quicker"
		---@type quicker.SetupOptions
		opts = {},
	},
}
