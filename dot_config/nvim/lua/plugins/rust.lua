return {
  "mrcjkb/rustaceanvim",
  opts = {
    server = {
      default_settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = false,
            targetDir = "target/analyzer",
            buildScripts = {
              enable = false,
            },
          },
        },
      },
    },
  },
}
