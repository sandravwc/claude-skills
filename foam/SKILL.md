---
name: foam
description: Operate this workstation's Foam notes vault (plain markdown files + wikilinks, git-backed) at ~/workdir/notes — log work progress, create/update pages and cheat sheets, capture journal entries, link related notes. Use whenever the user asks to note something down, log/journal work progress, update their notes, or otherwise mentions Foam/their notes vault.
---

# Foam vault

## Overview

Foam is a VS Code extension that adds wikilink autocomplete and backlinks on
top of a plain directory of markdown files. There's also an official `foam
mcp` server (`foam-cli`, docs at docs.foam.md/tools/cli/mcp/) exposing the
same graph — links, backlinks, tags, orphan/dead-end detection — as MCP
tools. It's registered project-scoped for this vault (`.mcp.json`, read-only,
no `--allow-writes`) — prefer its graph tools (`mcp__foam__*`, once
approved/connected) over hand-rolled regex over `[[...]]` for anything
graph-shaped (orphans, backlinks, dead links). For plain content reads and
edits, Read/Write/Edit/Grep on the files directly is still the normal path.

## This workstation's setup

- Vault: `~/workdir/notes`, a git repo (`git init` on 2026-09-19, no remote
  configured yet — `git push` will fail until one is added).
- This vault replaced a Logseq **DB-version** graph (migrated 2026-09-19,
  because Logseq's DB version broke git-diffable sync and namespace display).
  `MIGRATION-REVIEW.md` in the vault root documents what did and didn't carry
  over from that one-time conversion.
- Layout: what used to be Logseq's `category⁄subtopic` namespace convention
  is now real directories, e.g. `cheat sheet/mysql-major-upgrade.md`,
  `android/adb-debloat.md`. When creating a new page that conceptually
  belongs under an existing category, put it in that category's directory
  rather than flattening it at the vault root.
- Journal: one file per day at `journal/YYYY-MM-DD.md`, frontmatter
  `date: YYYY-MM-DD`. Journal entries are reference material (often TODO-style
  progress notes), not scratch — don't discard existing entries.
- Page frontmatter: `title:` is optional — Foam falls back to the first `#
  H1`, then the filename, if absent. Keep it where the migration set it
  (the page name, with a real `/` for what used to be a namespace) rather
  than stripping it.
- Tags: `tags: [...]` frontmatter and inline `#tag` are real, live Foam
  features — indexed and browsable via the Tag Explorer sidebar panel, not
  inert metadata. Foam renders each tag as its own graph node, so **never
  give a page a tag that's the same string as a category/directory it's
  already filed under** (e.g. don't tag `cheat sheet/jq.md` with `cheat
  sheet`) — that produces a tag-node and a note-node with an identical
  label, which look like duplicate/broken graph nodes. The migration did
  exactly this at first and it had to be undone (see `MIGRATION-REVIEW.md`).
  Directory placement already is the category; only add a tag for something
  that genuinely cuts across categories.
- No namespace feature: unlike OG Logseq, Foam does not auto-generate an
  index/hierarchy page per category. The directory tree (VS Code's file
  explorer) is the only built-in substitute. The flat `[[category/x]]` link
  lists on hub pages like `cheat sheet.md` are manual holdovers from
  Logseq's namespace view — they will not stay in sync automatically, so
  add a link there by hand when adding a new file under that category.
- Wikilinks: `[[category/page]]`, same syntax Logseq used. Foam resolves by
  path or unique basename and autocompletes on typing `[[`. A link to a page
  that doesn't exist yet renders as an unresolved placeholder — that's fine;
  only create the target file once there's real content for it.
- Every category directory needs a top-level `<category>.md` hub linking its
  children (`[[category/x]]` list, same shape as `cheat sheet.md`), even one
  with no body content of its own otherwise — without it, every file in that
  directory is an orphan in Foam's graph (no auto namespace edges, see
  above). Add the new page's link to the hub when creating one.
- `.markdownlint.json` at the vault root turns off rules that fight this
  vault's actual conventions (long real command lines, `<placeholder>`
  genericization, Logseq's inline `### label` bullets read as headings) —
  don't silence a *new* markdownlint warning by wrapping/reformatting real
  content; check whether it's one of these known-intentional patterns first
  and extend the config instead.
- **Never write company-, client-, or employer-identifying specifics into
  this vault**: no real customer/client names, no internal hostnames/domains,
  no credentials/API keys/tokens, no employee names beyond the user
  themself. Generalize hostnames (`db01.example.internal`), redact secrets
  (`<redacted>`), keep content technique-focused and reusable. This was a
  deliberate cleanup the user already did once (see `journal/2026-09-17.md`)
  — don't reintroduce that kind of content on their behalf.
- Prefer fenced code blocks for anything code/command/config-shaped, matching
  the style already used throughout the vault.
- No zero-width-space escaping needed for `[[ ... ]]` shell test syntax
  inside code blocks — that was a workaround for Logseq's CLI eagerly
  parsing every `[[...]]` as a wikilink even inside fenced code. Foam doesn't
  do that; write shell code exactly as it should run.

## Page style

The user writes these pages as personal shorthand/memory-jogs, not
documentation for a general reader. Match that register — do not write like
a tutorial or a wiki. Compiled from the pages the user actually authored (not
pages this assistant wrote):

- Label = 2-6 word noun/imperative fragment, lowercase, no terminal
  punctuation. Not a sentence. `"resize disk"`, `"create con"`, `"mod con"`
  — not `"How to resize a disk"`.
- The code block *is* the content. A label followed immediately by a fenced
  command is the default shape of a bullet; most bullets need nothing else.
- No motivation, background, or "why this matters" prose. State the action
  or fact, not the reasoning behind wanting it, unless a single short clause
  is truly required to disambiguate the label.
- Never explain what a tool/flag/concept generically is or why it's useful —
  assume the reader already knows or will look it up.
- Caveats, gotchas, sequencing ("on every node:", "then on master:"), and
  "won't work like this:" warnings go **inside the code block as
  comments/lines**, not as separate explanatory bullets or prose.
- Don't restate in prose what the code already shows, and don't pad the code
  with comments explaining what a command obviously does.
- No headers/sections/"Overview" framing unless the source material
  genuinely has distinct phases the user themself would separate — default
  is a flat bullet list.
- Nesting mirrors real execution order or real variants ("quick and dirty"
  vs. "somewhat fancy" as sibling sub-bullets), never conceptual/topical
  grouping added for tidiness.
- Leave typos, shorthand, mixed German/English, and raw pasted terminal
  history (prompts, timestamps) as-is when reusing the user's own words —
  don't proofread or formalize their voice. Do not introduce new
  spelling/grammar looseness on this assistant's own writing to fake the
  voice, either.
- Incomplete stubs are fine and expected: a bare label with no code, `"tbd"`,
  or a dangling `-` placeholder. Don't feel pressure to complete or pad them.
- Omit anything not load-bearing for reproducing the action: no "Goal:"
  framing, no scope statements, no citations/sources, no incidental
  command that only mattered for one specific occasion, unless it's actually
  core to the technique being recorded.
- When genericizing a real command (per the no-company-specifics rule
  above), swap the real value for a placeholder and move on — don't add a
  sentence about why it was swapped.

## Typical asks and how to serve them

- "Log/note that I did X" / "add today's progress" / "add a TODO" → open or
  create `journal/<today, YYYY-MM-DD>.md` (frontmatter `date: <today>` if
  the file is new) and append a top-level bullet.
- "Update my `<topic>` cheat sheet" / "add this to my notes" → Grep the
  vault for the topic to find the right file (check the likely category
  directory first, e.g. `cheat sheet/`); Edit it to append/update a bullet,
  or Write a new file with `title:` frontmatter if it doesn't exist yet.
- Prefer nested markdown bullets (sibling/child list items, each idea its
  own bullet) over flattening structured content — multiple steps, code
  blocks, variants — into one paragraph or one giant block. This mirrors
  the block-per-idea shape Logseq enforced; nothing enforces it here, so
  keep doing it deliberately.
- Link related pages with `[[category/page]]` rather than restating content
  that already lives on another page.

## Stop hook: session-log prompt

This workstation has a Claude Code **Stop hook** wired in
`~/.claude/settings.json` that fires when a session ends. It does *not*
write to the vault itself — an LLM can't reliably tell trivial edits from
things worth journaling, so it defers to the user.

- Script: `hooks/foam-stop-log.sh` in this repo, installed at
  `~/.claude/hooks/foam-stop-log.sh`.
- Behavior: once per session, if any tool was used, it blocks the Stop
  (`{"decision":"block","reason":...}`) so the assistant asks the user (via
  `AskUserQuestion`) whether to log a note to today's journal file, and what
  to write. Declining or "skip" ends it there — nothing is written without
  explicit go-ahead.
- Dedup: touches a marker file at
  `~/.cache/claude-code-foam-stop/<session_id>` so it only blocks once per
  session (also checks the hook's own `stop_hook_active` flag to avoid
  looping).

Install on a new machine:

```sh
mkdir -p ~/.claude/hooks
cp hooks/foam-stop-log.sh ~/.claude/hooks/foam-stop-log.sh
chmod +x ~/.claude/hooks/foam-stop-log.sh
```

Then merge this into `~/.claude/settings.json` (merge into existing
`hooks.Stop`, don't overwrite):

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/foam-stop-log.sh", "timeout": 15 }
        ]
      }
    ]
  }
}
```

Needs `jq` on PATH. Requires opening `/hooks` once (or restarting Claude
Code) after first install so the settings watcher picks up the new hooks
directory.

## Tips

- The vault is a plain git repo — commit like any other repo when the user
  asks; there's no separate sync/export step the way Logseq needed one.
- If a wikilink's target category doesn't have a directory yet, create it by
  just writing the first file into it (`mkdir -p` semantics via Write).
