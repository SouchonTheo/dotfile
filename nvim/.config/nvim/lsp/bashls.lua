-- bashls shells out to shellcheck for diagnostics, install both to get them
return {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  root_markers = { ".git" },
}
