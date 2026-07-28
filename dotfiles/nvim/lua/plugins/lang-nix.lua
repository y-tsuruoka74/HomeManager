-- nilはmason経由（cargo build）だとnil自身のgit依存がSSH URLでauth失敗するため、
-- Nixで用意済みのシステムバイナリ（modules/packages.nix の pkgs.nil）を使う
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          mason = false,
        },
      },
    },
  },
}
