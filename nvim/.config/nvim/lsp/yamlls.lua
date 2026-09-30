local ok, schemastore = pcall(require, "schemastore")

return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose" },
  root_markers = { ".git" },
  settings = {
    yaml = {
      schemaStore = { enable = false, url = "" }, -- SchemaStore.nvim provides the list instead
      schemas = ok and schemastore.yaml.schemas() or {},
    },
  },
}
