return {
  {
    'vim-skk/skkeleton',
    dependencies = { 'vim-denops/denops.vim' },
    event = 'VeryLazy',
    config = function()
      vim.keymap.set('i', '<C-j>', '<Plug>(skkeleton-enable)', { silent = true })
      vim.keymap.set('c', '<C-j>', '<Plug>(skkeleton-enable)', { silent = true })
      vim.keymap.set('t', '<C-j>', '<Plug>(skkeleton-enable)', { silent = true })

      local dictionary_path
      local os_name = vim.loop.os_uname().sysname
      if os_name == "Linux" then
        dictionary_path = "~/.local/share/skk/SKK-JISYO.L"
      elseif os_name == "Darwin" then
        dictionary_path = "~/Library/Application Support/AquaSKK/SKK-JISYO.L"
      else
        dictionary_path = nil
      end

      vim.cmd([[
        call skkeleton#config({
          \ 'eggLikeNewline': v:true,
          \ 'globalDictionaries': [']] .. dictionary_path .. [[']
          \ })
      ]])
      vim.cmd([[
        call skkeleton#register_keymap('input', ';', 'henkanPoint')
      ]])
    end
  }
}

