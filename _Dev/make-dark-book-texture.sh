#!/usr/bin/env bash
# Build Art/Book/TextureKit-DarkParchment.png, the Book UI skin used for
# parchment readables while the Dark theme is selected.
#
# Rows 0-1152 (page): the Dark theme's own dialogue page (Theme_Dark/Parchment.png),
#   scaled ~0.7% so its page lines up with the Book UI parchment page. Its torn
#   grey edge, inner band and shadow come across unchanged.
# Rows 1152-1408 (bottom strip for short pages): the bottom 256 rows of that page
#   with the same fade-in at the top as the stock parchment strip.
# Rows 1408-2048 (dividers, close button, icons): copied from the Metal kit,
#   which is already drawn for a dark page.
#
# The page interior is made fully opaque (the Dark theme's is 85%): the bottom
# strip is drawn over the text to hide it as it scrolls, and the two page pieces
# overlap, so translucency would show ghosted text and a darker seam.
#
# Requires ImageMagick 7. Run from anywhere: _Dev/make-dark-book-texture.sh
set -euo pipefail

cd "$(dirname "$0")/.."
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

dark=Art/Theme_Dark/Parchment.png
metal=Art/Book/TextureKit-Metal.png
out=Art/Book/TextureKit-DarkParchment.png

# Dark page body is 777x905 at +124+125; the Book parchment body is 771x899 at +126+127.
magick "$dark" -crop 1024x1152+0+0 +repage \
    -resize "$((1024 * 771 / 777))x$((1152 * 899 / 905))!" \
    -channel A -level 0,85% +channel \
    -background none -gravity northwest -extent 1024x1152-3-3 \
    +repage PNG32:"$tmp/page.png"

# In game the page piece overlaps the strip's top 40 rows. There, the strip's
# opaque page fades in over 38 rows (matching the stock strip, so text scrolling
# under it fades out), and its shadow is dropped so it doesn't double up with the
# page piece's shadow into a dark line either side of the page.
magick "$tmp/page.png" -crop 1024x256+0+896 +repage \
    -channel A -fx 'u.a >= 0.99 ? u.a * min(1, j / 38) : (j >= 40 ? u.a : 0)' +channel \
    PNG32:"$tmp/strip.png"

magick "$metal" -crop 1024x640+0+1408 +repage PNG32:"$tmp/ui.png"

magick "$tmp/page.png" "$tmp/strip.png" "$tmp/ui.png" -background none -append +repage PNG32:"$out"
echo "Wrote $out"
