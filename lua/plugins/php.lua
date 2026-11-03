-- System phpactor + hover that works for DocBlock type names.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Override default K for all LSPs (same Snacks lsp filter as LazyVim's K,
        -- so this replaces vim.lsp.buf.hover instead of losing to it).
        ["*"] = {
          keys = {
            {
              "K",
              function()
                require("config.phpactor_hover").hover()
              end,
              desc = "Hover",
            },
          },
        },
        phpactor = {
          mason = false,
          cmd = { "phpactor", "language-server" },
          enabled = true,
        },
      },
    },
  },
}
