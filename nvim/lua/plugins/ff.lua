return {
  -- {
  --   'vim-fall/fall.vim',
  --   dependencies = { 'vim-denops/denops.vim' },
  --   event = 'VeryLazy',
  --   config = function()
  --     vim.keymap.set('n', '<leader>ff', '<cmd>Fall file<cr>', { silent = true })
  --     vim.keymap.set('n', '<leader>fg', '<cmd>Fall rg<cr>', { silent = true })
  --     vim.keymap.set('n', '<leader>fb', '<cmd>Fall buffer<cr>', { silent = true })
  --     vim.keymap.set('n', '<leader>fh', '<cmd>Fall help<cr>', { silent = true })
  --     vim.keymap.set('n', '<leader>fl', '<cmd>Fall line<cr>', { silent = true })
  --   end
  -- }
  {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Telescope',
    opts = {},
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
    end
  }
}
