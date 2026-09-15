-- treesitter (main branch: no setup() function, just install + start)
local parsers = {
  "rust", "lua", "vim", "vimdoc", "query",
  "markdown", "markdown_inline",
  "c", "zig", "toml", "json", "yaml", "bash", "regex", "diff",
}
require("nvim-treesitter").install(parsers)

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local ft = args.match
    local lang = vim.treesitter.language.get_lang(ft) or ft
    if vim.treesitter.language.add(lang) then
      pcall(vim.treesitter.start, args.buf, lang)
    end
  end,
})

-- sticky header showing the enclosing fn / impl / mod while scrolling
require("treesitter-context").setup({
  max_lines = 3,
  multiline_threshold = 1, -- one line per scope level
  trim_scope = "outer",
  mode = "cursor",
})

require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },
  move = { set_jumps = true }, -- jumplist-aware
})

-- blink.cmp v2 needs a native fuzzy lib (cargo build --release, stable toolchain).
-- Official vim.pack recipe (:h blink-cmp-installation-vim.pack): build() is a
-- no-op when the lib for the current commit already exists, so this only blocks
-- on first install and after an update. A PackChanged autocmd doesn't work here:
-- it would be registered after vim.pack.add() already fired the install event.
local blink = require("blink.cmp")
blink.build():wait(60000)

blink.setup({
  -- "enter" preset: <CR> accepts (falls back to newline when the menu is closed),
  -- <Tab>/<S-Tab> navigate snippets, <C-y> also accepts.
  -- <Tab> also accepts the Copilot ghost text (native inline completion, lsp.lua):
  -- a function in a blink keymap chain stops the chain when it returns true,
  -- and inline_completion.get() returns true exactly when it applied a candidate.
  keymap = {
    preset = "enter",
    ["<Tab>"] = {
      "snippet_forward",
      function() return vim.lsp.inline_completion.get() end,
      "fallback",
    },
  },
  appearance = { nerd_font_variant = "mono" },
  snippets = { preset = "mini_snippets" },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
    -- off: it would fight the Copilot inline ghost text for the same virtual text
    ghost_text = { enabled = false },
  },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "path", "snippets", "buffer", "lazydev" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    rust = { "rustfmt" },
    c = { "clang-format" },
    zig = { "zigfmt" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    toml = { "taplo" },
  },
  -- Returning nil disables format-on-save for that buffer.
  -- Escape hatches (both toggled by <leader>tf / <leader>tF in keymaps.lua):
  --   vim.b.disable_autoformat = this buffer only
  --   vim.g.disable_autoformat = globally, for repos whose style isn't ours
  format_on_save = function(bufnr)
    if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then return end
    if vim.api.nvim_buf_line_count(bufnr) > 5000 then return end
    return { lsp_format = "fallback", timeout_ms = 1500 }
  end,
})
