return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup({
        window = { width = 90 }
      })
    end
  },

  {
    "preservim/vim-markdown",
    ft = "markdown",
    config = function()
      vim.cmd([[
        highlight htmlH1 cterm=bold ctermfg=4
        highlight htmlH2 cterm=bold ctermfg=4
        highlight htmlH3 cterm=bold ctermfg=4
        highlight htmlBold cterm=bold ctermfg=0
        highlight htmlItalic cterm=italic ctermfg=0
        highlight markdownCode ctermfg=2
        highlight markdownCodeBlock ctermfg=2
        highlight markdownListMarker ctermfg=1
        highlight markdownLink ctermfg=4
        highlight markdownLinkText ctermfg=5
      ]])
    end
  },

  {
    "gbprod/substitute.nvim",
    config = function()
      require("substitute").setup({
        highlight_substituted_text = {
          enabled = true,
          timer = 300,
        },
      })
    end,
  },

  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("frecency")
    end,
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },

  {
    "gelguy/wilder.nvim",
    config = function()
      require("config.wilder")
    end,
  },

  -- Claude Code CLI integration (full terminal, auto-reload)
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claude-code").setup({
        window = {
          position = "vertical",
          width = 80,
        },
      })
    end,
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Open Claude Code" },
      { "<leader>ax", "<cmd>ClaudeCodeClose<cr>", desc = "Close Claude Code" },
    },
  },

  -- Claude API for quick code help (select + ask)
  {
    "IntoTheNull/claude.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claude").setup({
        api_key = os.getenv("ANTHROPIC_API_KEY"),
        model = "claude-sonnet-4-20250514",
      })
    end,
    keys = {
      { "<leader>aa", "<cmd>ClaudeChat<cr>", desc = "Claude chat" },
      { "<leader>ae", "<cmd>ClaudeExplain<cr>", mode = "v", desc = "Explain selection" },
      { "<leader>ar", "<cmd>ClaudeRefactor<cr>", mode = "v", desc = "Refactor selection" },
      { "<leader>af", "<cmd>ClaudeFix<cr>", mode = "v", desc = "Fix selection" },
    },
  },
}
