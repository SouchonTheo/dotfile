require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons() -- compat for plugins that expect nvim-web-devicons

require("mini.ai").setup()

-- gs* instead of the default s*: flash owns `s` (keymaps.lua), and with both
-- defined `s` had to wait timeoutlen and `sa`/`sd`/`sr`… hijacked the jump.
-- Same layout as LazyVim: gsa add, gsd delete, gsr replace, gsf/gsF find, gsh highlight.
require("mini.surround").setup({
  mappings = {
    add = "gsa", delete = "gsd", find = "gsf", find_left = "gsF",
    highlight = "gsh", replace = "gsr", update_n_lines = "gsn",
  },
})
require("mini.move").setup()
require("mini.pairs").setup()

-- only hex colors here: TODO/FIXME/HACK/NOTE are todo-comments' job (highlight + ]t/[t)
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = { hex_color = hipatterns.gen_highlighter.hex_color() },
})

require("mini.indentscope").setup({
  symbol = "│",
  options = { try_as_border = true },
})
require("mini.extra").setup()

local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    { mode = "n", keys = "<leader>" },
    { mode = "x", keys = "<leader>" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
  },
  clues = {
    { mode = "n", keys = "<leader>f", desc = "+find" },
    { mode = "n", keys = "<leader>s", desc = "+search" },
    { mode = "n", keys = "<leader>g", desc = "+git" },
    { mode = "n", keys = "<leader>c", desc = "+code" },
    { mode = "n", keys = "<leader>b", desc = "+buffer" },
    { mode = "n", keys = "<leader>l", desc = "+lsp" },
    { mode = "n", keys = "<leader>t", desc = "+toggle" },
    { mode = "n", keys = "<leader>T", desc = "+test" },
    { mode = "n", keys = "<leader>d", desc = "+debug" },
    { mode = "n", keys = "<leader>p", desc = "+plugins" },
    { mode = "n", keys = "<leader>S", desc = "+session" },
    { mode = "n", keys = "<leader>v", desc = "+visits" },
    { mode = "n", keys = "<leader>y", desc = "+yank path" },
    { mode = "x", keys = "<leader>y", desc = "+yank path" },
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    { mode = "n", keys = "gs", desc = "+surround" },
    { mode = "x", keys = "gs", desc = "+surround" },
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
  window = {
    delay = 300,
    config = { width = "auto" }, -- border comes from 'winborder'
  },
})

require("mini.pick").setup({
  mappings = {
    move_down = "<C-j>",
    move_up   = "<C-k>",
  },
})

-- Every picker opens with its preview pane already shown. mini.pick has no
-- option for that, but it fires MiniPickStart and reads keys from typeahead,
-- so feeding its toggle_preview key (<Tab>) right at start does the job.
-- <Tab> again hides it for the current picker.
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("theo_pick_preview", { clear = true }),
  pattern = "MiniPickStart",
  callback = function() vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "t", false) end,
})

require("mini.files").setup({
  -- Swap l/L so `l` (the natural "open") closes the explorer when the target
  -- is a file (go_in_plus). On directories it still just descends, so nav is
  -- unchanged. `L` keeps the explorer open to open + browse on.
  mappings = {
    go_in      = "L",
    go_in_plus = "l",
  },
  windows = { preview = true, width_focus = 30, width_preview = 60 },
  options = { use_as_default_explorer = true },
})

-- each tab shows its error / warning count, so a broken file is visible from
-- any other buffer (rust-analyzer publishes diagnostics for the whole workspace).
local sev = vim.diagnostic.severity
require("mini.tabline").setup({
  format = function(buf_id, label)
    local counts = vim.diagnostic.count(buf_id)
    local suffix = ""
    if (counts[sev.ERROR] or 0) > 0 then suffix = suffix .. "\u{F057} " .. counts[sev.ERROR] .. " " end
    if (counts[sev.WARN] or 0) > 0 then suffix = suffix .. "\u{F071} " .. counts[sev.WARN] .. " " end
    return MiniTabline.default_format(buf_id, label) .. suffix
  end,
})
-- Colour for those counters. mini.tabline escapes "%" in labels, so a highlight
-- can't be injected from format(); instead the finished tabline string is
-- post-processed: inside each "%#MiniTablineX#…" segment the counters get
-- "%#MiniTablineXError#" / "%#MiniTablineXWarn#" (diagnostic fg on that tab's bg),
-- then the segment's own group is restored.
local tab_groups = {
  "MiniTablineCurrent", "MiniTablineVisible", "MiniTablineHidden",
  "MiniTablineModifiedCurrent", "MiniTablineModifiedVisible", "MiniTablineModifiedHidden",
}
local function make_tabline_diag_hl()
  for _, base in ipairs(tab_groups) do
    local bg = vim.api.nvim_get_hl(0, { name = base, link = false }).bg
    for suffix, src in pairs({ Error = "DiagnosticError", Warn = "DiagnosticWarn" }) do
      local fg = vim.api.nvim_get_hl(0, { name = src, link = false }).fg
      vim.api.nvim_set_hl(0, base .. suffix, { fg = fg, bg = bg, bold = true })
    end
  end
end
make_tabline_diag_hl()

function _G.theo_tabline()
  local s = MiniTabline.make_tabline_string()
  local out, pos = {}, 1
  while true do
    local a, b, group = s:find("%%#(MiniTabline%w+)#", pos)
    if not a then table.insert(out, s:sub(pos)) break end
    table.insert(out, s:sub(pos, b))
    local nxt = s:find("%#", b + 1, true) or (#s + 1)
    local body = s:sub(b + 1, nxt - 1)
    body = body:gsub("(\u{F057} %d+)", "%%#" .. group .. "Error#%1%%#" .. group .. "#")
    body = body:gsub("(\u{F071} %d+)", "%%#" .. group .. "Warn#%1%%#" .. group .. "#")
    table.insert(out, body)
    pos = nxt
  end
  return table.concat(out)
end
vim.o.tabline = "%!v:lua.theo_tabline()"

local tabline_diag = vim.api.nvim_create_augroup("theo_tabline_diag", { clear = true })
-- the tabline only redraws on its own events, diagnostics arriving is not one of them
vim.api.nvim_create_autocmd("DiagnosticChanged", { group = tabline_diag, callback = function() vim.cmd.redrawtabline() end })
-- registered after mini.tabline's own ColorScheme hook, so its groups are already refreshed
vim.api.nvim_create_autocmd("ColorScheme", { group = tabline_diag, callback = make_tabline_diag_hl })
require("mini.statusline").setup({ use_icons = true })

require("mini.bufremove").setup()
-- Two targets off instead of silently overridden: ]t/[t belong to todo-comments
-- (keymaps.lua), ]d/[d to the native maps (they go through vim.diagnostic.jump,
-- hence the float on arrival configured in options.lua; bracketed's own don't).
require("mini.bracketed").setup({ treesitter = { suffix = "" }, diagnostic = { suffix = "" } })
require("mini.splitjoin").setup()
-- word-under-cursor highlight for buffers without an LSP (kdl, fish, toml…).
-- Where a server supports documentHighlight, lua/lsp/attach.lua disables it per buffer and
-- highlights the same *symbol* instead (semantic, not textual).
require("mini.cursorword").setup({ delay = 200 })
require("mini.jump").setup()        -- enhanced f/F/t/T (multi-line, ; repeats)
require("mini.trailspace").setup()

require("mini.misc").setup()
MiniMisc.setup_restore_cursor()

-- frecency-ranked file history, one store per cwd, plus manual labels
-- (e.g. "core", "wip"). Pickers and label maps live in keymaps.lua.
require("mini.visits").setup()

-- git hunks in the sign column + inline overlay (<leader>go). Owns the sign
-- column and hunk ops. Default maps from setup(): gh = apply hunk (operator),
-- gH = reset hunk, gh in visual = textobject, [h ]h = prev/next hunk (rebound in keymaps.lua).
require("mini.diff").setup({
  view = { style = "sign", signs = { add = "▎", change = "▎", delete = "▁" } },
})

-- :Git <anything> with completion, output in a split; MiniGit.show_at_cursor()
-- is the blame replacement (history of the line, or the commit under the cursor).
-- Also feeds the branch name to mini.statusline.
require("mini.git").setup()

-- sessions live in stdpath("data")/session; <leader>S* in keymaps.lua.
-- autowrite keeps the active session in sync on exit.
require("mini.sessions").setup({
  autoread = false, -- only handles a local Session.vim; the project logic is below
  autowrite = true, -- the active session is re-saved on exit, so you always land where you left
})

-- Nothing is restored on its own: `nvim` in a project lands on the starter,
-- whose first item is "Restore session <project>" when one exists (below).
-- <leader>Sr also restores it from anywhere.

-- The first save is automatic though: leaving nvim inside a git repo with at
-- least one real file open writes the project session if none is active yet
-- (autowrite already covers the case where one was restored or saved by hand).
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("theo_session_autosave", { clear = true }),
  callback = function()
    if vim.v.this_session ~= "" then return end
    if vim.fn.isdirectory(vim.uv.cwd() .. "/.git") == 0 then return end
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[b].buflisted and vim.bo[b].buftype == "" and vim.api.nvim_buf_get_name(b) ~= "" then
        MiniSessions.write(vim.fn.fnamemodify(vim.uv.cwd(), ":t"))
        return
      end
    end
  end,
})

require("mini.operators").setup({
  evaluate = { prefix = "g="  },
  exchange = { prefix = "gX"  }, -- moved (gx = URL open in 0.10+)
  multiply = { prefix = "gm"  },
  replace  = { prefix = ""    }, -- disabled (conflicts with grr = LSP references)
  sort     = { prefix = ""    }, -- disabled (gs = mini.surround prefix); :sort does the job
})

local starter = require("mini.starter")
starter.setup({
  evaluate_single = true,
  items = {
    -- the session named after the cwd, as a single item at the top (only when it exists)
    function()
      local name = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
      if not MiniSessions.detected[name] then return {} end
      return { { name = "Restore session " .. name, action = function() MiniSessions.read(name) end, section = "Project" } }
    end,
    starter.sections.builtin_actions(),
    starter.sections.sessions(5, true),
    starter.sections.recent_files(10, false),
    starter.sections.recent_files(10, true),
  },
  content_hooks = {
    starter.gen_hook.adding_bullet("  "),
    starter.gen_hook.aligning("center", "center"),
  },
  header = table.concat({
    "  ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
    "  ████╗  ██║██║   ██║██║████╗ ████║",
    "  ██╔██╗ ██║██║   ██║██║██╔████╔██║",
    "  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
  }, "\n"),
  footer = "",
})
