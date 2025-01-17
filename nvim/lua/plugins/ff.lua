return {
  {
    'vim-fall/fall.vim',
    dependencies = { 'vim-denops/denops.vim' },
    event = 'VeryLazy',
    config = function()
      vim.keymap.set('n', '<leader>ff', '<cmd>Fall file<cr>', { silent = true })
      vim.keymap.set('n', '<leader>fg', '<cmd>Fall rg<cr>', { silent = true })
      vim.keymap.set('n', '<leader>fb', '<cmd>Fall buffer<cr>', { silent = true })
      vim.keymap.set('n', '<leader>fh', '<cmd>Fall help<cr>', { silent = true })
      vim.keymap.set('n', '<leader>fl', '<cmd>Fall line<cr>', { silent = true })
    end
  }
}
