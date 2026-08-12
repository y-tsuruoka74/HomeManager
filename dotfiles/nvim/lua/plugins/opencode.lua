return {
  {
    "sudo-tee/opencode.nvim",
    config = function()
      require("opencode").setup({})
    end,
    dependencies = {
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "markdown", "opencode_output" },
        },
        ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
      },
      -- 補完はblink.cmp（LazyVimデフォルト）を使用
      "saghen/blink.cmp",
      -- ファイル選択はsnacks.nvim（lazy.luaでsnacks_pickerを導入済み）を使用
      "folke/snacks.nvim",
    },
  },
}
