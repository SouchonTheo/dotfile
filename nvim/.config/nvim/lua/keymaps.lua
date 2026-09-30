local map = vim.keymap.set

-- window navigation (hjkl only, no arrows on purpose)
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })

-- splits: the key draws the separator (| = vertical, - = horizontal)
map("n", "<leader>|", "<C-w>v", { desc = "Split window right" })
map("n", "<leader>-", "<C-w>s", { desc = "Split window below" })

for _, k in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  map({ "n", "v" }, k, "<nop>")
end

-- mini.pick
map("n", "<leader><space>", "<cmd>Pick files<cr>",       { desc = "Find files" })
map("n", "<leader>ff",      "<cmd>Pick files<cr>",       { desc = "Find files" })
map("n", "<leader>fg",      "<cmd>Pick git_files<cr>",   { desc = "Git files" })
map("n", "<leader>fb",      "<cmd>Pick buffers<cr>",     { desc = "Buffers" })
map("n", "<leader>fr",      "<cmd>Pick oldfiles<cr>",    { desc = "Recent files" })
map("n", "<leader>fh",      "<cmd>Pick help<cr>",        { desc = "Help" })
map("n", "<leader>fk",      "<cmd>Pick keymaps<cr>",     { desc = "Keymaps" })
map("n", "<leader>fd",      "<cmd>Pick diagnostic<cr>",  { desc = "Diagnostics (workspace)" })
map("n", "<leader>fD", function()
  MiniExtra.pickers.diagnostic({ get_opts = { severity = vim.diagnostic.severity.ERROR } })
end, { desc = "Errors only (workspace)" })

map("n", "<leader>sg", "<cmd>Pick grep_live<cr>", { desc = "Grep project" })
map("n", "<leader>sw", function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end,
  { desc = "Grep word under cursor" })
map("n", "<leader>sd", function()
  MiniPick.builtin.grep_live({}, { source = { cwd = vim.fn.expand("%:p:h") } })
end, { desc = "Grep dir of current file" })
map("n", "<leader>sr", "<cmd>Pick resume<cr>", { desc = "Resume last picker" })

-- mini.files
map("n", "<leader>e", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" or vim.fn.filereadable(path) == 0 then path = vim.uv.cwd() end
  require("mini.files").open(path)
end, { desc = "Explorer (current file dir)" })

map("n", "<leader>E", function()
  require("mini.files").open(vim.uv.cwd())
end, { desc = "Explorer (cwd)" })

-- grug-far
map("n", "<leader>sR", "<cmd>GrugFar<cr>", { desc = "Search & Replace" })
map("v", "<leader>sR", "<cmd>GrugFarVisual<cr>", { desc = "Search & Replace (selection)" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "Next buffer" })
map("n", "<leader>bd", function() require("mini.bufremove").delete(0, false) end, { desc = "Delete buffer (keep split)" })
map("n", "<leader>bD", function() require("mini.bufremove").delete(0, true) end, { desc = "Delete buffer (force)" })

map("i", "jk", "<esc>",              { desc = "Escape" })
map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- terminal mode.
-- <Esc> alone would break TUIs running inside :terminal (lazygit, htop),
-- so the escape hatch is a double tap.
map("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
for _, k in ipairs({ "h", "j", "k", "l" }) do
  map("t", "<C-" .. k .. ">", "<C-\\><C-n><C-w>" .. k, { desc = "Go to " .. k .. " window" })
end

-- quickfix: the vanilla hub for grug-far / :Pick grep results.
-- ]q / [q navigation already comes from mini.bracketed.
map("n", "<leader>q", function()
  local open = vim.iter(vim.fn.getwininfo()):any(function(w) return w.quickfix == 1 end)
  vim.cmd(open and "cclose" or "copen")
end, { desc = "Toggle quickfix list" })
-- every workspace diagnostic into the quickfix, then ]q / [q to walk through them
map("n", "<leader>Q", function() vim.diagnostic.setqflist({ open = true }) end, { desc = "Diagnostics to quickfix" })

-- keep cursor centered on half-page jumps and search hits
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n",     "nzvzz")
map("n", "N",     "Nzvzz")

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next TODO" })
map("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Prev TODO" })

-- git hunks via mini.diff (gh / gH operators come from its setup)
map("n", "]h", function() MiniDiff.goto_hunk("next") end,  { desc = "Next hunk" })
map("n", "[h", function() MiniDiff.goto_hunk("prev") end,  { desc = "Prev hunk" })
map("n", "]H", function() MiniDiff.goto_hunk("last") end,  { desc = "Last hunk" })
map("n", "[H", function() MiniDiff.goto_hunk("first") end, { desc = "First hunk" })
local function hunk_at_cursor(action)
  local l = vim.fn.line(".")
  MiniDiff.do_hunks(0, action, { line_start = l, line_end = l })
end
map("n", "<leader>gs", function() hunk_at_cursor("apply") end, { desc = "Stage hunk under cursor" })
map("n", "<leader>gr", function() hunk_at_cursor("reset") end, { desc = "Reset hunk under cursor" })
map("n", "<leader>gS", function() MiniDiff.do_hunks(0, "apply") end, { desc = "Stage all hunks in buffer" })
map("n", "<leader>go", function() MiniDiff.toggle_overlay(0) end, { desc = "Toggle diff overlay" })
-- mini.git: history of the current line (git log -L), or the commit if the cursor is on a hash
map("n", "<leader>gb", function() MiniGit.show_at_cursor() end, { desc = "Blame / history at cursor" })
map("n", "<leader>gB", "<cmd>Git blame -- %<cr>", { desc = "Blame whole file" })
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit" })

-- lsp, <leader>l: the native 0.11 commands, nothing custom
map("n", "<leader>li", "<cmd>LspInfo<cr>",    { desc = "LSP: info (clients, roots, health)" })
map("n", "<leader>ll", "<cmd>LspLog<cr>",     { desc = "LSP: open log" })
map("n", "<leader>lr", "<cmd>LspRestart<cr>", { desc = "LSP: restart" })

-- diagnostics: ]d [d ]D [D are native (float on arrival via jump.on_jump in
-- options.lua), only the severity-filtered variants are added.
local function diag_jump(count, severity)
  return function() vim.diagnostic.jump({ count = count, severity = severity }) end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[e", diag_jump(-1, vim.diagnostic.severity.ERROR), { desc = "Prev error" })
map("n", "]e", diag_jump(1,  vim.diagnostic.severity.ERROR), { desc = "Next error" })
map("n", "[w", diag_jump(-1, vim.diagnostic.severity.WARN),  { desc = "Prev warning" })
map("n", "]w", diag_jump(1,  vim.diagnostic.severity.WARN),  { desc = "Next warning" })

-- flash.nvim
map({ "n", "x", "o" }, "s", function() require("flash").jump() end,            { desc = "Flash jump" })
map({ "n", "x", "o" }, "S", function() require("flash").treesitter() end,      { desc = "Flash treesitter (jump to a node)" })
map("o",               "r", function() require("flash").remote() end,          { desc = "Remote flash (e.g. yr = yank remote)" })
map({ "x", "o" },      "R", function() require("flash").treesitter_search() end, { desc = "Treesitter search" })

-- treesitter textobjects + movement
local ok_sel, ts_select = pcall(require, "nvim-treesitter-textobjects.select")
local ok_mv,  ts_move   = pcall(require, "nvim-treesitter-textobjects.move")
if ok_sel then
  local objs = {
    f = "function",
    c = "class",     -- = struct/impl/trait in Rust
    a = "parameter",
    l = "loop",
    o = "call",
    k = "comment",
  }
  for key, name in pairs(objs) do
    map({ "x", "o" }, "a" .. key, function() ts_select.select_textobject("@" .. name .. ".outer", "textobjects") end,
      { desc = "around " .. name })
    map({ "x", "o" }, "i" .. key, function() ts_select.select_textobject("@" .. name .. ".inner", "textobjects") end,
      { desc = "inside " .. name })
  end
end
if ok_mv then
  map({ "n", "x", "o" }, "]m", function() ts_move.goto_next_start("@function.outer", "textobjects") end,     { desc = "Next function start" })
  map({ "n", "x", "o" }, "[m", function() ts_move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Prev function start" })
  map({ "n", "x", "o" }, "]M", function() ts_move.goto_next_end("@function.outer", "textobjects") end,       { desc = "Next function end" })
  map({ "n", "x", "o" }, "[M", function() ts_move.goto_previous_end("@function.outer", "textobjects") end,   { desc = "Prev function end" })
  map({ "n", "x", "o" }, "]]", function() ts_move.goto_next_start("@class.outer", "textobjects") end,        { desc = "Next class/struct start" })
  map({ "n", "x", "o" }, "[[", function() ts_move.goto_previous_start("@class.outer", "textobjects") end,    { desc = "Prev class/struct start" })
  map({ "n", "x", "o" }, "][", function() ts_move.goto_next_end("@class.outer", "textobjects") end,          { desc = "Next class/struct end" })
  map({ "n", "x", "o" }, "[]", function() ts_move.goto_previous_end("@class.outer", "textobjects") end,      { desc = "Prev class/struct end" })
  map({ "n", "x", "o" }, "]a", function() ts_move.goto_next_start("@parameter.outer", "textobjects") end,    { desc = "Next parameter" })
  map({ "n", "x", "o" }, "[a", function() ts_move.goto_previous_start("@parameter.outer", "textobjects") end,{ desc = "Prev parameter" })
end

map("n", "<leader>cw", function() MiniTrailspace.trim() end, { desc = "Trim trailing whitespace" })
map("n", "<leader>th", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = "Toggle inlay hints" })
map("n", "<leader>tc", function()
  local on = not vim.lsp.inline_completion.is_enabled()
  vim.lsp.inline_completion.enable(on)
  vim.notify("Copilot inline completion: " .. (on and "ON" or "OFF"))
end, { desc = "Toggle Copilot inline completion" })

-- read by conform's format_on_save in setup/coding.lua
map("n", "<leader>tf", function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify("Format on save: " .. (vim.b.disable_autoformat and "OFF (buffer)" or "ON (buffer)"))
end, { desc = "Toggle format on save (buffer)" })
map("n", "<leader>tF", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify("Format on save: " .. (vim.g.disable_autoformat and "OFF (global)" or "ON (global)"))
end, { desc = "Toggle format on save (global)" })

-- neotest, <leader>T = +test
map("n", "<leader>Tr", function() require("neotest").run.run() end,                        { desc = "Run nearest test" })
map("n", "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end,       { desc = "Run file tests" })
map("n", "<leader>Tl", function() require("neotest").run.run_last() end,                    { desc = "Run last test" })
map("n", "<leader>Ts", function() require("neotest").summary.toggle() end,                  { desc = "Toggle summary" })
map("n", "<leader>To", function() require("neotest").output.open({ enter = true }) end,     { desc = "Show output" })
map("n", "<leader>TO", function() require("neotest").output_panel.toggle() end,             { desc = "Toggle output panel" })
map("n", "<leader>TS", function() require("neotest").run.stop() end,                        { desc = "Stop test" })

-- dap, <leader>d = +debug
map("n", "<leader>db", function() require("dap").toggle_breakpoint() end,                   { desc = "Toggle breakpoint" })
map("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, { desc = "Conditional breakpoint" })
map("n", "<leader>dc", function() require("dap").continue() end,                            { desc = "Continue / start" })
map("n", "<leader>di", function() require("dap").step_into() end,                           { desc = "Step into" })
map("n", "<leader>do", function() require("dap").step_over() end,                           { desc = "Step over" })
map("n", "<leader>dO", function() require("dap").step_out() end,                            { desc = "Step out" })
map("n", "<leader>dr", function() require("dap").repl.toggle() end,                         { desc = "Toggle REPL" })
map("n", "<leader>du", function() require("dapui").toggle() end,                            { desc = "Toggle DAP UI" })
map("n", "<leader>dt", function() require("dap").terminate() end,                           { desc = "Terminate" })
-- rustaceanvim picks the right cargo target/test to debug
map("n", "<leader>dR", function() vim.cmd.RustLsp("debuggables") end,                       { desc = "Rust debuggables" })

-- rust-analyzer's flycheck keeps cargo's raw output to itself (LSP only gets the
-- parsed diagnostics), so show the compile log by re-running the same command in
-- a terminal split. Same flags + same target dir as rust-analyzer (ide.lua), so
-- cargo finds the artifacts fresh and just replays the cached output: instant
-- after a save, no rebuild. `q` closes the split once the command is done.
local function cargo_log()
  local client = vim.lsp.get_clients({ bufnr = 0, name = "rust-analyzer" })[1]
  local root = client and client.root_dir or vim.fs.root(0, { "Cargo.lock", "Cargo.toml" })
  if not root then return vim.notify("No cargo workspace found", vim.log.levels.WARN) end
  vim.cmd("botright 15split")
  vim.cmd.enew()
  vim.fn.jobstart({ "cargo", "clippy", "--workspace", "--all-targets", "--target-dir", "target/analyzer" },
    { cwd = root, term = true })
  vim.bo.buflisted = false
  map("n", "q", "<cmd>bwipeout!<cr>", { buffer = true, desc = "Close compile log" })
end

-- rustaceanvim under <leader>c (+code), buffer-local so it only exists in rust files.
-- Free letters only: cf (format), cd (line diagnostics) and cw (trim) are taken globally.
-- Rename is the native grn, not duplicated here.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("theo_rust_keymaps", { clear = true }),
  pattern = "rust",
  callback = function(ev)
    local rmap = function(lhs, cmd, desc)
      map("n", lhs, function() vim.cmd.RustLsp(cmd) end, { buffer = ev.buf, desc = desc })
    end
    rmap("<leader>cr", "runnables",        "Rust: runnables")
    rmap("<leader>ct", "testables",        "Rust: testables")
    rmap("<leader>cm", "expandMacro",      "Rust: expand macro")
    rmap("<leader>ce", "explainError",     "Rust: explain error (rustc --explain)")
    rmap("<leader>cD", "renderDiagnostic", "Rust: render diagnostic (cargo style)")
    rmap("<leader>cc", "openCargo",        "Rust: open Cargo.toml")
    rmap("<leader>cp", "parentModule",     "Rust: parent module")
    rmap("<leader>co", "openDocs",         "Rust: open docs.rs for symbol")
    rmap("<leader>cj", "joinLines",        "Rust: join lines")
    rmap("<leader>ca", "codeAction",       "Rust: code action (grouped)")
    rmap("<leader>cL", "logFile",          "Rust: rust-analyzer server log")
    map("n", "<leader>cl", cargo_log, { buffer = ev.buf, desc = "Rust: compile log (cargo clippy)" })
  end,
})

-- render-markdown (setup/editor.lua) under <leader>c, buffer-local like the rust
-- maps above, so <leader>cm doesn't clash with Rust's expand macro. Rendering is
-- on by default in normal mode; toggle it to see the raw text.
-- <leader>cM toggles the live-preview.nvim browser tab (setup/editor.lua).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("theo_markdown_keymaps", { clear = true }),
  pattern = "markdown",
  callback = function(ev)
    map("n", "<leader>cm", "<cmd>RenderMarkdown buf_toggle<cr>", { buffer = ev.buf, desc = "Markdown: toggle rendering" })
    map("n", "<leader>cM", function()
      local lp = require("livepreview")
      if lp.is_running() then
        lp.close()
        vim.notify("Markdown preview stopped")
      else
        vim.cmd("LivePreview start")
      end
    end, { buffer = ev.buf, desc = "Markdown: browser preview (toggle)" })
  end,
})

-- mini.visits, <leader>v = +visits (frecency history; labels group files by hand)
map("n", "<leader>vv", function() MiniExtra.pickers.visit_paths() end,            { desc = "Visits (this cwd, frecency)" })
map("n", "<leader>vV", function() MiniExtra.pickers.visit_paths({ cwd = "" }) end, { desc = "Visits (all cwds)" })
map("n", "<leader>vl", function() MiniExtra.pickers.visit_labels() end,           { desc = "Pick by label" })
map("n", "<leader>va", function() MiniVisits.add_label() end,                     { desc = "Add label to file" })
map("n", "<leader>vr", function() MiniVisits.remove_label() end,                  { desc = "Remove label from file" })
map("n", "]v", function() MiniVisits.iterate_paths("forward") end,                { desc = "Next visited file" })
map("n", "[v", function() MiniVisits.iterate_paths("backward") end,               { desc = "Prev visited file" })

-- treesitter-context
map("n", "<leader>tx", "<cmd>TSContext toggle<cr>", { desc = "Toggle sticky scope header" })
map("n", "gK", function() require("treesitter-context").go_to_context(vim.v.count1) end, { desc = "Go to enclosing scope" })

-- copy the current file path, <leader>y = +yank
-- relative = from cwd (what you paste in a PR comment or a chat), absolute = full path
local function yank(text)
  vim.fn.setreg("+", text)
  vim.notify("Copied: " .. text)
end
map("n", "<leader>yp", function() yank(vim.fn.expand("%:.")) end,  { desc = "Yank relative path" })
map("n", "<leader>yP", function() yank(vim.fn.expand("%:p")) end,  { desc = "Yank absolute path" })
map("n", "<leader>yf", function() yank(vim.fn.expand("%:t")) end,  { desc = "Yank file name" })
map("n", "<leader>yl", function() yank(vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")) end,
  { desc = "Yank path:line" })
map("n", "<leader>yL", function() yank(vim.fn.expand("%:p") .. ":" .. vim.fn.line(".")) end,
  { desc = "Yank absolute path:line" })
-- visual: path:first-last of the selection
map("v", "<leader>yl", function()
  local first, last = vim.fn.line("v"), vim.fn.line(".")
  if first > last then first, last = last, first end
  local range = first == last and tostring(first) or (first .. "-" .. last)
  yank(vim.fn.expand("%:.") .. ":" .. range)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Yank path:lines" })

-- mini.sessions, <leader>S = +session
map("n", "<leader>Sl", function() MiniSessions.select() end, { desc = "Load session" })
map("n", "<leader>Sd", function() MiniSessions.select("delete") end, { desc = "Delete session" })
map("n", "<leader>Sr", function()
  local name = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
  if MiniSessions.detected[name] then MiniSessions.read(name) else MiniSessions.read() end
end, { desc = "Restore project session (else latest)" })
map("n", "<leader>Ss", function()
  vim.ui.input({ prompt = "Session name: ", default = vim.fn.fnamemodify(vim.uv.cwd(), ":t") }, function(name)
    if name and name ~= "" then MiniSessions.write(name) end
  end)
end, { desc = "Save session" })

-- vim.pack, <leader>p = +plugins
map("n", "<leader>pu", function() vim.pack.update() end,                                    { desc = "Update all plugins" })
map("n", "<leader>pl", function() vim.print(vim.pack.get()) end,                            { desc = "List installed plugins" })
