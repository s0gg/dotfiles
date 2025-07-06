return {
  {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Telescope',
    opts = {},
  },
  {
    "vim-fall/fall.vim",
    dependencies = { 'vim-denops/denops.vim' },
    event = 'VeryLazy',
    keys = {
      { '<leader>ff', '<cmd>Fall file<cr>', mode = { 'n' }, desc = "Find files", silent = true },
      { '<leader>fg', '<cmd>Fall rg<cr>', mode = { 'n' }, desc = "Find ripgrep", silent = true },
      { '<leader>fb', '<cmd>Fall buffer<cr>', mode = { 'n' }, desc = "Find buffer", silent = true },
      { '<leader>fh', '<cmd>Fall help<cr>', mode = { 'n' }, desc = "Find help", silent = true },
      { '<leader>fl', '<cmd>Fall line<cr>', mode = { 'n' }, desc = "Find line", silent = true },
      { '<leader>fo', '<cmd>Fall oldfiles<cr>', mode = { 'n' }, desc = "Find oldfiles", silent = true },
    },
  }
}
