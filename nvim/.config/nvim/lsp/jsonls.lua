-- JSON: pnpm add -g vscode-langservers-extracted. Formatting comes from the server
-- (provideFormatter) and conform falls back to it when prettier is not installed.
-- Schemas: SchemaStore matches by file name (package.json, tsconfig.json,
-- .vscode/settings.json, .github/workflows/*.yml, ...), giving completion + validation.
local ok, schemastore = pcall(require, "schemastore")

return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  init_options = { provideFormatter = true },
  settings = {
    json = {
      schemas = ok and schemastore.json.schemas() or {},
      validate = { enable = true },
    },
  },
}
