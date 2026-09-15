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
o.termguicolors = true
o.signcolumn = "yes"
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.wrap = false
o.swapfile = false
o.undofile = true
o.undodir = vim.fn.stdpath("state") .. "/undo"
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = false
o.scrolloff = 8
o.updatetime = 200
o.timeoutlen = 400
o.splitbelow = true
o.splitright = true
o.clipboard = "unnamedplus"
o.cursorline = true
o.confirm = true
o.mouse = "a"
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
  float = { border = "rounded" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    },
  },
})
