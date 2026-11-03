local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function() vim.hl.on_yank() end,
})

-- reload buffers changed on disk outside nvim.
-- 'autoread' alone does nothing until something triggers a file check: that
-- trigger is :checktime, which we fire whenever focus or the buffer changes.
-- Skips command-line mode so it can't interrupt a :command being typed.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave", "BufEnter" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" and vim.fn.mode() ~= "c" then
      vim.cmd.checktime()
    end
  end,
})

-- terminal resized (niri column width preset, maximize): rebalance the splits
-- in every tab instead of leaving them squashed at their old proportions
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current)
  end,
})

-- prose filetypes: spell + hard wrap.
-- 72 columns on gitcommit is the git convention (50 for the subject line).
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spell = true
    -- "en" only: nvim ships en.utf-8.spl but not fr.utf-8.spl, and a missing
    -- .spl makes spellfile.vim prompt to download it on every buffer open.
    -- To add French: :set spelllang=en,fr then :mkspell, or drop
    -- fr.utf-8.spl into ~/.local/share/nvim/site/spell/.
    vim.opt_local.spelllang = "en"
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 72
  end,
})

-- `q` closes throwaway/utility buffers instead of needing :q<cr>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("quick_close"),
  pattern = {
    "help", "qf", "man", "checkhealth", "lspinfo",
    "startuptime", "grug-far-help", "dap-float",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, desc = "Close window" })
  end,
})
