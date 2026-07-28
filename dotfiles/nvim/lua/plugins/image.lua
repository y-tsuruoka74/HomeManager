-- snacks.nvim の image ビューア。PNG/SVG等を開くとフローティングウィンドウで表示する。
-- WezTerm は Kitty Graphics Protocol のインライン表示（テキスト埋め込み）には非対応だが、
-- 単体ファイルのフローティング表示は動作する。ImageMagick (magick/convert CLI) が必要。
return {
  "folke/snacks.nvim",
  opts = {
    image = {
      enabled = true,
      formats = {
        "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif",
        "mp4", "mov", "avi", "mkv", "webm", "pdf", "icns",
        "svg", "eps", -- ベクター画像もImageMagick経由でラスタライズして表示
      },
    },
  },
}
