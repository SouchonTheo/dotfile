-- signs and hunk operations are mini.diff's job (setup/mini.lua); gitsigns
-- is kept for what mini.diff lacks: blame.
require("gitsigns").setup({ signcolumn = false, numhl = false, linehl = false })

require("todo-comments").setup({ signs = false })

require("grug-far").setup()

require("render-markdown").setup({
  file_types = { "markdown" },
  completions = { lsp = { enabled = true } },
})

require("fidget").setup({
  progress = {
    display = {
      done_icon = "✓",
      progress_icon = { pattern = "dots" },
    },
  },
  notification = {
    override_vim_notify = true, -- route vim.notify() through fidget instead of the cmdline
    window = { winblend = 0, border = "rounded" },
  },
})

vim.g.lazygit_floating_window_scaling_factor = 0.95
vim.g.lazygit_use_neovim_remote = 0

require("flash").setup({
  modes = {
    char = {
      enabled = false, -- don't hijack f/F/t/T, mini.jump handles those
    },
    search = {
      enabled = false, -- don't hijack /, keeps default search behavior
    },
  },
  label = { rainbow = { enabled = true, shade = 5 } },
})

-- motion hints above each line, hidden until <leader>tp
require("precognition").setup({
  startVisible = false,
  showBlankVirtLine = false,
  hints = {
    Caret      = { text = "^",  prio = 2 },
    Dollar     = { text = "$",  prio = 1 },
    MatchingPair = { text = "%", prio = 5 },
    w          = { text = "w",  prio = 10 },
    b          = { text = "b",  prio = 9  },
    e          = { text = "e",  prio = 8  },
    W          = { text = "W",  prio = 7  },
    B          = { text = "B",  prio = 6  },
    E          = { text = "E",  prio = 4  },
  },
  gutterHints = {
    G          = { text = "G",  prio = 10 },
    gg         = { text = "gg", prio = 9  },
    PrevParagraph = { text = "{", prio = 8 },
    NextParagraph = { text = "}", prio = 8 },
  },
})
