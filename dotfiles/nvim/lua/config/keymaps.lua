-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save File" })

-- snacks.nvim のインライン画像表示が環境依存で機能しないため、Preview.appで開く確実な代替手段
vim.keymap.set("n", "<leader>ip", function()
  vim.fn.jobstart({ "open", vim.fn.expand("%:p") }, { detach = true })
end, { desc = "Open file in Preview.app" })
