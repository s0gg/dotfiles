return {
	"weizheheng/ror.nvim",
	ft = "ruby",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"rcarriga/nvim-notify",
		"stevearc/dressing.nvim",
	},
	config = function()
		require("dressing").setup({
			input = {
				min_width = { 60, 0.9 },
			},
			select = {
				-- telescope = require('telescope.themes').get_ivy({...})
				telescope = require("telescope.themes").get_dropdown({ layout_config = { height = 15, width = 90 } }),
			},
		})
		require("ror").setup({})

		vim.keymap.set("n", "<Leader>rc", ":lua require('ror.commands').list_commands()<CR>", { silent = true })
	end,
}
