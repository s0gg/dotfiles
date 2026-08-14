-- s0gg's nvim config

local function is_wsl()
	return os.getenv("WSL_DISTRO_NAME") ~= nil
end

vim.g.mapleader = " "

local opt = vim.opt
opt.fileencoding = "utf-8"
opt.swapfile = false
opt.hidden = true
-- opt.clipboard:append({ "unnamedplus" })
opt.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = "WslClipboard",
  copy = {
    ["+"] = "wl-copy",
  },
  paste = {
    ["+"] = function()
      return vim.fn.systemlist('wl-paste | tr -d "\r"')
    end,
    ["*"] = "wl-paste",
  },
  cache_enabled = 1,
}
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
