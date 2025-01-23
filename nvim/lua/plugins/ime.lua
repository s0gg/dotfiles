return {
  {
    'vim-skk/skkeleton',
    dependencies = { 'vim-denops/denops.vim' },
    event = 'VeryLazy',
    config = function()
      vim.keymap.set('i', '<C-j>', '<Plug>(skkeleton-enable)', { silent = true })
      vim.keymap.set('c', '<C-j>', '<Plug>(skkeleton-enable)', { silent = true })
      vim.keymap.set('t', '<C-j>', '<Plug>(skkeleton-enable)', { silent = true })

      vim.cmd([[
        call skkeleton#config({
          \ 'eggLikeNewline': v:true,
          \ 'globalDictionaries': ["~/.local/share/skk/SKK-JISYO.L"]
          \ })
      ]])
      vim.cmd([[
        call skkeleton#register_keymap('input', ';', 'henkanPoint')
      ]])
    end
  }
}

