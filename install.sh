#!/usr/bin/env bash
# Copy this fork's tracked addon files over the installed DialogueUI folder.
#
# Only files tracked by git are copied, and nothing in the target is deleted,
# so the release-only assets (extra fonts/sounds) and your saved settings are
# left untouched.
#
# Usage: ./install.sh [path/to/Interface/AddOns/DialogueUI]
#        or set DIALOGUEUI_DIR.
set -euo pipefail

DEFAULT_DIR="$HOME/Faugus/battlenet/drive_c/Program Files (x86)/World of Warcraft/_classic_beta_/Interface/AddOns/DialogueUI"
TARGET="${1:-${DIALOGUEUI_DIR:-$DEFAULT_DIR}}"

cd "$(dirname "$0")"

if [[ ! -d "$TARGET" ]]; then
    echo "error: $TARGET does not exist." >&2
    echo "Install DialogueUI normally first, then pass its folder as an argument." >&2
    exit 1
fi

branch=$(git branch --show-current)
if [[ "$branch" != "tweaks" ]]; then
    echo "warning: on branch '$branch', not 'tweaks'." >&2
fi

if ! git diff --quiet HEAD; then
    echo "warning: uncommitted changes will be installed too." >&2
fi

# Everything tracked except repo plumbing, dev tools and this fork's own files.
git ls-files -z \
    | grep -zv -e '^\.git' -e '^_Dev/' -e '^README\.md$' -e '^install\.sh$' -e '^update\.sh$' \
    | rsync -a --from0 --files-from=- ./ "$TARGET/"

echo "Installed $(git describe --tags --always) ($branch) into:"
echo "  $TARGET"
echo "Run /reload in game."
