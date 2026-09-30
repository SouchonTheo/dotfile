-- nvim 0.11+ already provides grn (rename), grr (references), gra (code action),
-- gri (implementation), grt (type def), K (hover), gO (symbols).
-- Only what's missing, or what we prefer aliased to leader, is added here.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end

    -- same symbol highlighted under the cursor (LspReferenceText/Read/Write),
    -- semantic rather than textual: `x` the local, not every `x` in the file.
    -- mini.cursorword steps aside in these buffers.
    if client and client:supports_method("textDocument/documentHighlight") then
      vim.b[ev.buf].minicursorword_disable = true
      local group = vim.api.nvim_create_augroup("theo_lsp_highlight_" .. ev.buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group, buffer = ev.buf, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group, buffer = ev.buf, callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = group, buffer = ev.buf,
        callback = function()
          vim.lsp.buf.clear_references()
          vim.b[ev.buf].minicursorword_disable = nil
          pcall(vim.api.nvim_del_augroup_by_name, "theo_lsp_highlight_" .. ev.buf)
        end,
      })
    end

    -- Copilot ghost text. <Tab> accepts (wired in blink's keymap, setup/coding.lua),
    -- <M-]> / <M-[> cycle candidates, <leader>tc toggles (keymaps.lua).
    if client and client:supports_method("textDocument/inlineCompletion") then
      vim.lsp.inline_completion.enable(true, { bufnr = ev.buf })
      map("i", "<M-]>", function() vim.lsp.inline_completion.select({ count = 1 }) end, "Copilot: next suggestion")
      map("i", "<M-[>", function() vim.lsp.inline_completion.select({ count = -1 }) end, "Copilot: prev suggestion")
    end

    -- gd / gri with the noise removed: when rust-analyzer returns locations both
    -- in the workspace and inside dependency sources (~/.cargo/registry, ~/.cargo/git,
    -- ~/.rustup toolchains, node_modules for JS/TS), keep only the workspace ones. A single hit jumps
    -- directly, several go to the quickfix list. If everything lives in a dependency
    -- (e.g. gd on a std/serde item), nothing is filtered and you land there as usual.
    local function is_dependency_path(path)
      return path:find("/%.cargo/registry/", 1) ~= nil
        or path:find("/%.cargo/git/", 1) ~= nil
        or path:find("/%.rustup/toolchains/", 1) ~= nil
        or path:find("/node_modules/", 1, true) ~= nil
    end
    local function jump_filtered(lsp_fn)
      return function()
        lsp_fn({
          on_list = function(list)
            local items = list.items or {}
            local workspace_items = vim.tbl_filter(function(item)
              local path = item.filename or (item.bufnr and vim.api.nvim_buf_get_name(item.bufnr)) or ""
              return not is_dependency_path(path)
            end, items)
            if #workspace_items > 0 then items = workspace_items end
            if #items == 0 then return vim.notify("No location found", vim.log.levels.INFO) end
            if #items == 1 then
              local item = items[1]
              local path = item.filename or vim.api.nvim_buf_get_name(item.bufnr)
              vim.cmd("normal! m'") -- keep <C-o> working
              vim.cmd.edit(vim.fn.fnameescape(path))
              vim.api.nvim_win_set_cursor(0, { item.lnum, math.max((item.col or 1) - 1, 0) })
              return
            end
            -- several hits: mini.pick (preview opens by itself, see setup/mini.lua;
            -- <C-j>/<C-k> move, <CR> jumps, <Esc> cancels)
            local pick_items = vim.tbl_map(function(item)
              return {
                path = item.filename or vim.api.nvim_buf_get_name(item.bufnr),
                lnum = item.lnum,
                col = item.col,
                text = vim.trim(item.text or ""),
              }
            end, items)
            MiniPick.start({ source = { items = pick_items, name = list.title } })
          end,
        })
      end
    end
    map("n", "gd",  jump_filtered(vim.lsp.buf.definition),     "LSP: definition (workspace first)")
    map("n", "gri", jump_filtered(vim.lsp.buf.implementation), "LSP: implementations (workspace first)")
    map("n", "grt", jump_filtered(vim.lsp.buf.type_definition), "LSP: type definition (workspace first)")
    map("n", "grr", jump_filtered(function(opts) vim.lsp.buf.references(nil, opts) end), "LSP: references (workspace first)")
    map("n", "gO",  function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end, "LSP: document symbols")
    map("n", "gD", vim.lsp.buf.declaration, "LSP: declaration")
    -- through conform (same formatters as format-on-save), LSP as fallback
    map("n", "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, "Format")
    -- diagnostics maps ([d ]d [e ]e [w ]w <leader>cd) are global, see keymaps.lua
  end,
})
