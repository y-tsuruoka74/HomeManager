return {
  "hiasr/vim-zellij-navigator.nvim",
  config = function()
    require("vim-zellij-navigator").setup()
  end,
  keys = {
    { "<C-h>", "<cmd>wincmd h<cr>", desc = "Navigate left" },
    { "<C-j>", "<cmd>wincmd j<cr>", desc = "Navigate down" },
    { "<C-k>", "<cmd>wincmd k<cr>", desc = "Navigate up" },
    { "<C-l>", "<cmd>wincmd l<cr>", desc = "Navigate right" },
  },
}
