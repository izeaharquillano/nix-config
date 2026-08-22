return {
  -- { "plugin/name", enabled = false },

  -- disables inlay_hints
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  }
}
