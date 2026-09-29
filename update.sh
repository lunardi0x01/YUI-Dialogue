#!/usr/bin/env bash
# Move the 'tweaks' branch onto the newest upstream release tag.
#
# 'tweaks' is always "one upstream release + our commits on top". This script
# finds the release it is currently based on, fetches upstream, and replays our
# commits onto the newest release with git rebase. It also mirrors upstream's
# main into this fork's main.
#
# Usage: ./update.sh [tag]    (defaults to the newest upstream tag)
set -euo pipefail

cd "$(dirname "$0")"

if [[ "$(git branch --show-current)" != "tweaks" ]]; then
    echo "error: switch to the 'tweaks' branch first." >&2
    exit 1
fi
if ! git diff --quiet HEAD; then
    echo "error: commit or stash your changes first." >&2
    exit 1
fi

git fetch --quiet upstream --tags --force

old_base=$(git describe --tags --abbrev=0 HEAD)
new_base=${1:-$(git tag --sort=-creatordate | head -n 1)}

# Keep the fork's main in step with upstream (fast-forward only).
git push --quiet origin refs/remotes/upstream/main:refs/heads/main \
    || echo "note: could not fast-forward origin/main; skipping." >&2

if [[ "$old_base" == "$new_base" ]]; then
    echo "Already based on $new_base; nothing to do."
    exit 0
fi

echo "Rebasing our commits from $old_base onto $new_base:"
git log --oneline "$old_base"..HEAD

if ! git rebase --onto "$new_base" "$old_base"; then
    cat >&2 <<EOF

Upstream changed code our commits touch, so the rebase stopped on a conflict.
Fix the conflicted files, then 'git add <file>' and 'git rebase --continue'.
To back out and stay on $old_base: 'git rebase --abort'.
When it finishes: git push --force-with-lease origin tweaks && ./install.sh
EOF
    exit 1
fi

git push --force-with-lease origin tweaks
echo
echo "Now based on $new_base. Update DialogueUI in your addon manager (or"
echo "download $new_base), then run ./install.sh and /reload."
