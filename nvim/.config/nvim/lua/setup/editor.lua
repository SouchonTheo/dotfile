require("todo-comments").setup({ signs = false })

require("grug-far").setup()

require("render-markdown").setup({
  file_types = { "markdown" },
  completions = { lsp = { enabled = true } },
})

-- browser preview with mermaid / KaTeX, refreshed on every edit (no save needed).
-- dynamic_root serves from the file's directory, so relative images resolve
-- even when the file lives outside the cwd.
require("livepreview.config").set({
  dynamic_root = true,
  sync_scroll = true,
  picker = "mini.pick",
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

