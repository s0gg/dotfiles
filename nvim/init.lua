-- s0gg's nvim config

local function is_wsl()
	return os.getenv("WSL_DISTRO_NAME") ~= nil
end

vim.g.mapleader = " "

local opt = vim.opt
opt.fileencoding = "utf-8"
opt.swapfile = false
opt.hidden = true
if not is_wsl() then
	-- only not in WSL because startup performance is worse
	opt.clipboard:append({ "unnamedplus" })
end
opt.wildmenu = true
opt.showcmd = true
opt.hlsearch = true
opt.incsearch = true
opt.termguicolors = true
opt.background = "dark"
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.showmatch = true
opt.signcolumn = "yes"
opt.colorcolumn = { 80, 100, 120 }
opt.scrolloff = 5
opt.sidescrolloff = 8
opt.wrap = false
opt.list = true
opt.listchars:append({ space = "∙", eol = "↲" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "html", "json", "javascript", "typescript", "typescriptreact" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "astro" },
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})

vim.keymap.set("n", "<space>ts", "<cmd>vsplit +term<cr>", { silent = true, desc = "Open terminal in vertical split" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins", {
	defaults = { lazy = true },
	install = { colorscheme = { "tokyonight" } },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
