-- live-server コマンド本体は modules/packages.nix (Nix) で導入済みのため
-- npm install は行わない
return {
  "barrett-ruth/live-server.nvim",
  cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggle" },
  keys = {
    { "<leader>ls", "<cmd>LiveServerToggle<cr>", desc = "Live Server Toggle" },
  },
  config = function()
    require("live-server").setup()

    -- 停止し忘れたまま nvim を終了しても live-server プロセスが残り続けないようにする
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        pcall(vim.cmd, "LiveServerStop")
      end,
    })
  end,
}
