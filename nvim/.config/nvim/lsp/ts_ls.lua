-- JS/TS: pnpm add -g typescript typescript-language-server. Uses the project's
-- node_modules/typescript when there is one, the global one otherwise.
-- Formatting goes through prettier (conform), ts_ls is the fallback.
local inlay_hints = {
  includeInlayParameterNameHints = "literals",
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript", "javascriptreact", "javascript.jsx",
    "typescript", "typescriptreact", "typescript.tsx",
  },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  init_options = { hostInfo = "neovim" },
  settings = {
    javascript = { inlayHints = inlay_hints },
    typescript = { inlayHints = inlay_hints },
  },
}
