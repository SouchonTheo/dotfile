-- leader must be set before plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

for _, p in ipairs({
  "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
  "netrwPlugin", -- replaced by mini.files
  "matchparen",  -- paren-highlight off on purpose (matchit KEPT: gives % on if/end, do/end)
  "rplugin",
  -- NB: the guard for runtime/plugin/spellfile.vim is `loaded_spellfile_plugin`,
  -- NOT `loaded_spellfile`, the latter silently does nothing. This plugin is
  -- what prompts "No spell file found for X. Download? [y/N]" and blocks startup.
  "spellfile_plugin",
}) do
  vim.g["loaded_" .. p] = 1
end

local o = vim.opt
o.number = true
o.relativenumber = true -- current line keeps its absolute number (number = true), others count from it
o.signcolumn = "yes"
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.wrap = false
o.swapfile = false
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.hlsearch = true -- <Esc> clears it (keymaps.lua)
o.scrolloff = 8
o.updatetime = 200
o.timeoutlen = 400
o.splitbelow = true
o.splitright = true
o.clipboard = "unnamedplus"
o.cursorline = true
o.confirm = true
-- reload buffers changed outside nvim (git checkout, rebase, stow).
-- needs the checktime autocmd in autocmds.lua to actually fire.
o.autoread = true
-- default border for ALL floats (LSP hover, signature, diagnostic float).
-- nvim 0.11+, replaces per-plugin `border = "rounded"` boilerplate.
o.winborder = "rounded"
-- per-project .nvim.lua / .nvimrc, with a trust prompt on first load (:h 'exrc')
o.exrc = true

-- native treesitter folding, everything open by default, fold with za/zM/zR.
-- foldtext="" keeps the folded line syntax-highlighted (nvim 0.10+).
o.foldmethod = "expr"
o.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
o.foldtext   = ""
o.foldlevel  = 99

vim.diagnostic.config({
  -- short inline text on every line for visibility, PLUS the full multi-line
  -- diagnostic under the cursor via native virtual_lines.
  -- current_line = false is what keeps the two from stacking on the same line:
  -- virtual_lines owns the cursor line, virtual_text owns all the others.
  virtual_text = { spacing = 2, prefix = "●", source = "if_many", current_line = false },
  virtual_lines = { current_line = true },
  severity_sort = true,
  underline = true,
  -- every jump (native ]d [d ]D [D and the [e ]e [w ]w maps) opens the diagnostic
  -- float on arrival. `float = true` per call is deprecated since 0.12.
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
  -- Nerd Font glyphs written as \u{} escapes so they can't silently turn into ""
  -- again when the file goes through a terminal that doesn't render them.
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\u{F057}", -- nf-fa-times_circle
      [vim.diagnostic.severity.WARN]  = "\u{F071}", -- nf-fa-warning
      [vim.diagnostic.severity.INFO]  = "\u{F05A}", -- nf-fa-info_circle
      [vim.diagnostic.severity.HINT]  = "\u{F400}", -- nf-oct-light_bulb
    },
    -- line number coloured by severity: with relative numbers, a red number in
    -- the gutter is the first thing the eye catches on the screen
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
    },
  },
})
