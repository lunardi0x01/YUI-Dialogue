# DialogueUI — personal tweaks

A personal fork of [Peterodox/YUI-Dialogue](https://github.com/Peterodox/YUI-Dialogue)
(the **Dialogue UI** World of Warcraft addon). It is the upstream addon unchanged,
plus three extra toggles in its settings panel and a dark look for readables.

## What this fork adds

The three options are **off by default**. The only change you'll see without ticking
anything is the dark readables, and only with the Dark theme selected.

| Option | Where in settings | What it does |
|---|---|---|
| **Hide XP Bar** | UI → under *Hide UI* | Hides the full-width XP bar DialogueUI draws at the bottom of the screen while the game UI is hidden. Only available while *Hide UI* is on. |
| **Hide Keybind Labels** | UI | Removes the key badges (Space, Esc, gamepad buttons) from dialogue buttons, and the `1.` `2.` `3.` prefixes on gossip options. The keys still work; only the labels go away. |
| **Hide Warband Completed Icon** | UI → Quest | Hides the check mark shown on quests another character on your account has already completed. It is removed from both the quest header and the NPC's quest list. |
| **Dark readables** (no toggle) | Follows *Theme* | With the Dark theme selected, parchment books and letters open on a dark parchment page instead of the light one. Stone and metal readables already had a dark look and are unchanged. |

Each change is a single commit on the `tweaks` branch, so `git log` shows exactly
what differs from upstream.

## Why a fork instead of contributing upstream

- **The author has turned down this kind of option.** An XP bar toggle was requested
  in [#155](https://github.com/Peterodox/YUI-Dialogue/issues/155). It was declined
  because the settings panel is already crowded and niche options make the important
  ones harder to find. That's a reasonable call for an addon with a large user base,
  and these toggles are personal preference.
- **Editing the installed addon doesn't last.** Every addon update overwrites the
  files, and the changes silently disappear. Keeping them as commits in a fork means
  they can be re-applied to each new release in one step.

Keybind hiding is also an open upstream request
([#224](https://github.com/Peterodox/YUI-Dialogue/issues/224)). If upstream ships
its own version, drop that commit from this fork.

## How it stays in sync with upstream

```
upstream release tag (e.g. v1.0.5-f)
 └─ Add Hide XP Bar option
     └─ Add Hide Keybind Labels option
         └─ Add Hide Warband Completed Icon option      ← tweaks
```

- **`tweaks`** (the default branch here): the latest upstream **release tag** with
  our commits on top. It follows release tags rather than upstream `main`, because
  the release is what's actually installed in the game.
- **`main`**: a plain mirror of upstream `main`, with nothing of ours in it.
- **Remotes** in the local clone: `origin` is this fork. `upstream` is
  Peterodox/YUI-Dialogue, set to fetch-only so nothing can be pushed there by accident.

When a new release comes out, `update.sh` replays our commits onto it with
`git rebase`. Because `tweaks` is rewritten, it is pushed with `--force-with-lease`.
That's normal for a personal patch branch, but don't base other work on it.

## Installing

The repo alone isn't a complete addon. A few fonts and sounds only ship in the
official release download. So install DialogueUI normally first, then put this
fork's code on top:

```bash
git clone https://github.com/lunardi0x01/YUI-Dialogue.git ~/Projects/YUI-Dialogue
cd ~/Projects/YUI-Dialogue
git remote add upstream https://github.com/Peterodox/YUI-Dialogue.git
git remote set-url --push upstream DISABLED
./install.sh            # then /reload in game
```

`install.sh` copies only the files tracked in git into the installed DialogueUI
folder. It never deletes anything, so release-only assets and your saved settings
aren't touched. The default target is the Faugus / Battle.net `_classic_beta_`
install. For any other install, pass the folder path as an argument or set
`DIALOGUEUI_DIR`.

## When DialogueUI updates

Updating DialogueUI (addon manager or manual download) wipes the tweaks from the
game folder. The options vanish from the settings panel, but your saved choices are
kept. To get them back:

```bash
cd ~/Projects/YUI-Dialogue
./update.sh      # fetch upstream, replay our commits onto the newest release, push
./install.sh     # copy onto the freshly updated addon
```

Then `/reload` in game.

**If `update.sh` stops on a conflict**, upstream changed code near one of our
edits. Git marks the conflicted files. Fix them, `git add` them, then run
`git rebase --continue`. Afterwards run `git push --force-with-lease origin tweaks`
and `./install.sh`. To bail out and stay on the old release: `git rebase --abort`.
Each tweak is small (a setting default, a checkbox, an English label and one or
two `if` checks), so conflicts should be easy to resolve.

To target a specific release instead of the newest one: `./update.sh v1.0.6-a`.

## Files

| File | Purpose |
|---|---|
| `install.sh` | Copy the tracked addon files into the game's DialogueUI folder |
| `update.sh` | Move `tweaks` onto the newest upstream release and push |
| `README.md` | This file |

None of these are copied into the game folder.

---

All addon code and assets belong to Peterodox and the upstream contributors. This
fork only adds the changes listed above.
