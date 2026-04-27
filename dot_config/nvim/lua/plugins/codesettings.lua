return {
  "mrjones2014/codesettings.nvim",
  lazy = false,
  opts = {},
  init = function()
    vim.lsp.config("*", {
      before_init = function(_, config)
        require("codesettings").with_local_settings(config.name, config)
      end,
    })
  end,
}
