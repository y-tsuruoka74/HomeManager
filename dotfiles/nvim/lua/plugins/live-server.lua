-- live-server コマンド本体は modules/packages.nix (Nix) で導入済みのため
-- npm install は行わない
return {
  "barrett-ruth/live-server.nvim",
  cmd = { "LiveServerStart", "LiveServerStop" },
  keys = {
    { "<leader>ls", "<cmd>LiveServerStart<cr>", desc = "Live Server Start" },
    { "<leader>lS", "<cmd>LiveServerStop<cr>", desc = "Live Server Stop" },
  },
  config = true,
}
