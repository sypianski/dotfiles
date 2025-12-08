local wilder = require('wilder')

wilder.setup({
  modes = {':', '/', '?'},
})

wilder.set_option('pipeline', {
  wilder.branch(
    wilder.cmdline_pipeline({
      language = 'vim',
      fuzzy = 1,
    }),
    wilder.vim_search_pipeline()
  ),
})
