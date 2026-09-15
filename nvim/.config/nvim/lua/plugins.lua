-- vim.pack: native package manager (nvim 0.12+).
-- This file ONLY declares which plugins to install.
-- Each plugin's setup() lives in lua/setup/{mini,coding,editor,ide}.lua.

vim.pack.add({
  -- theme.
  -- explicit `name`: the repo is catppuccin/nvim, without it the plugin would
  -- be installed into a directory called "nvim".
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },

  -- treesitter (main branch, new API)
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" }, -- sticky scope header

  -- mini.* (one repo each, lighter than the monorepo)
  { src = "https://github.com/echasnovski/mini.ai" },
  { src = "https://github.com/echasnovski/mini.comment" },
  { src = "https://github.com/echasnovski/mini.surround" },
  { src = "https://github.com/echasnovski/mini.move" },
  { src = "https://github.com/echasnovski/mini.pairs" },
  { src = "https://github.com/echasnovski/mini.hipatterns" },
  { src = "https://github.com/echasnovski/mini.icons" },
  { src = "https://github.com/echasnovski/mini.animate" },
  { src = "https://github.com/echasnovski/mini.indentscope" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/echasnovski/mini.files" },
  { src = "https://github.com/echasnovski/mini.extra" },
  { src = "https://github.com/echasnovski/mini.clue" },
  { src = "https://github.com/echasnovski/mini.tabline" },
  { src = "https://github.com/echasnovski/mini.statusline" },
  { src = "https://github.com/echasnovski/mini.bufremove" },
  { src = "https://github.com/echasnovski/mini.starter" },
  { src = "https://github.com/echasnovski/mini.snippets" },
  { src = "https://github.com/echasnovski/mini.bracketed" },
  { src = "https://github.com/echasnovski/mini.splitjoin" },
  { src = "https://github.com/echasnovski/mini.operators" },
  { src = "https://github.com/echasnovski/mini.cursorword" },
  { src = "https://github.com/echasnovski/mini.jump" },       -- enhanced f/F/t/T
  { src = "https://github.com/echasnovski/mini.trailspace" },
  { src = "https://github.com/echasnovski/mini.misc" },       -- restore cursor on file open
  { src = "https://github.com/echasnovski/mini.sessions" },   -- project sessions (<leader>S)
  { src = "https://github.com/echasnovski/mini.visits" },     -- frecency file history + labels (<leader>v)
  { src = "https://github.com/echasnovski/mini.diff" },       -- git hunks: signs, overlay, apply/reset

  -- snippet collection (consumed by mini.snippets)
  { src = "https://github.com/rafamadriz/friendly-snippets" },

  -- editor
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/folke/todo-comments.nvim" },
  { src = "https://github.com/MagicDuck/grug-far.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/folke/flash.nvim" },          -- label-jump motion
  { src = "https://github.com/tris203/precognition.nvim" }, -- motion hints

  -- completion. Copilot is not a plugin anymore: nvim 0.12 native
  -- vim.lsp.inline_completion + copilot-language-server, configured in lsp.lua.
  { src = "https://github.com/Saghen/blink.lib" },
  { src = "https://github.com/Saghen/blink.cmp" },

  -- format (lint handled by the LSPs: rust-analyzer/clippy, etc.)
  { src = "https://github.com/stevearc/conform.nvim" },

  -- LSP helpers + UI
  { src = "https://github.com/folke/lazydev.nvim" },
  { src = "https://github.com/b0o/SchemaStore.nvim" },      -- JSON/YAML schema catalog for jsonls / yamlls
  { src = "https://github.com/mrjones2014/codesettings.nvim" },
  { src = "https://github.com/j-hui/fidget.nvim" },

  -- git ui
  { src = "https://github.com/kdheepak/lazygit.nvim" },

  -- rust
  { src = "https://github.com/mrcjkb/rustaceanvim" },
  { src = "https://github.com/saecki/crates.nvim" },        -- Cargo.toml: versions, features, docs (in-process LSP)

  -- test
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/nvim-neotest/neotest" },

  -- debug (rustaceanvim drives the rust adapter via nvim-dap + codelldb)
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
})
