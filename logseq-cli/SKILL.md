---
name: logseq-cli
description: Operate this workstation's Logseq notes graph ("notes") via the Logseq command-line interface — log work progress, update or create pages/cheat sheets, capture journal entries, tag and query entities, run Datascript queries. Use whenever the user asks to note something down, log/journal work progress, update their Logseq notes, or otherwise mentions Logseq/their notes graph.
---

# Logseq CLI

## Overview

Use `logseq` to inspect and edit graph entities, run Datascript queries, and control graph/server lifecycle.

## This workstation's setup

- The user's personal/work notes live in a Logseq **DB-version** graph named `notes` (already set as the CLI's current graph — `--graph` can be omitted).
- This graph replaced an old markdown-file graph that used to live at `~/workdir/notes` and synced via git (git repo is gone). Its only remaining relevance is the page/namespace *format* it established — don't treat `~/workdir/notes/pages/*.md` as live data, the `notes` Logseq graph (via this CLI) is the source of truth now.
- Page naming: since DB-graphs reject literal "/" in page titles, this graph uses the fraction-slash character "⁄" (U+2044, *not* a regular slash) to represent the old namespace hierarchy, e.g. `cheat sheet⁄mysql-major-upgrade`. When creating a new page that conceptually belongs under an existing category (e.g. "cheat sheet", "kubernetes", "pacemaker"), follow the same `category⁄subtopic` title convention and tag the page with the top-level category via `--update-tags '["category"]'` (check existing tags first with `list tag`).
- **Never write company-, client-, or employer-identifying specifics into this graph**: no real customer/client names, no internal hostnames/domains, no credentials/API keys/tokens, no employee names beyond the user themself. Generalize hostnames (`db01.example.internal`), redact secrets (`<redacted>`), and keep content technique-focused and reusable rather than tied to one employer's environment. This was a deliberate, explicit cleanup the user did to this graph — do not reintroduce that kind of content when adding new notes on their behalf.
- Journal entries are **reference material, not scratch** — most likely used as TODO lists (`upsert task` against a journal page). Don't discard or treat journal content as disposable; it can still be wiped later, but only when the user explicitly asks.
- Prefer code blocks for anything code/command/config-shaped (commands, snippets, file contents, config, output dumps) rather than plain inline text — wrap it in a fenced block inside the block's content/title (e.g. `` ```sh\n...\n``` ``), matching the style already used throughout this graph.
- Don't fuss over formatting mechanics beyond what's needed for the CLI to actually accept the write (EDN escaping, defusing incidental `[[...]]`, code-fence syntax) — those are correctness requirements, not style. Where actual page content is concerned, terseness (see "Page style" below) matters far more than tidy structure.

## Page style

The user writes these pages as personal shorthand/memory-jogs, not documentation for a general reader. Match that register — do not write like a tutorial or a wiki. Compiled from the pages the user actually authored (not pages this assistant wrote):

- Label = 2-6 word noun/imperative fragment, lowercase, no terminal punctuation. Not a sentence. `"resize disk"`, `"create con"`, `"mod con"` — not `"How to resize a disk"`.
- The code block *is* the content. A label followed immediately by a fenced command is the default shape of a block; most blocks need nothing else.
- No motivation, background, or "why this matters" prose. State the action or fact, not the reasoning behind wanting it, unless a single short clause is truly required to disambiguate the label.
- Never explain what a tool/flag/concept generically is or why it's useful — assume the reader already knows or will look it up. Skip definitional filler entirely.
- Caveats, gotchas, sequencing ("on every node:", "then on master:"), and "won't work like this:" warnings go **inside the code block as comments/lines**, not as separate explanatory bullets or prose above/below it.
- Don't restate in prose what the code already shows, and don't pad the code with comments explaining what a command obviously does.
- No headers/sections/"Overview" framing unless the source material genuinely has distinct phases the user themself would separate — default is a flat bullet list.
- Nesting mirrors real execution order or real variants ("quick and dirty" vs. "somewhat fancy" as sibling sub-bullets), never conceptual/topical grouping added for tidiness.
- Leave typos, shorthand, mixed German/English, and raw pasted terminal history (prompts, timestamps) as-is when reusing the user's own words — don't proofread or formalize their voice. Do not introduce new spelling/grammar looseness on this assistant's own writing to fake the voice, either — just don't over-polish real content that's already there.
- Incomplete stubs are fine and expected: a bare label with no code, `"tbd"`, or a dangling `-` placeholder. Don't feel pressure to complete or pad them out.
- Omit anything not load-bearing for reproducing the action: no "Goal:" framing, no scope statements, no citations/sources, no generic illustrative examples, no incidental command that only mattered for one specific occasion (e.g. a one-off firewall rule from the session that produced the note) unless it's actually core to the technique being recorded.
- When genericizing a real command (per the no-company-specifics rule above), don't over-explain the substitution — swap the real value for a placeholder and move on, don't add a sentence about why it was swapped.

## Typical asks and how to serve them

- "Log/note that I did X" / "add today's progress" / "add a TODO" → `upsert task` targeting today's journal page (journal entries are treated as real reference material here, most often TODO-style tasks — not throwaway scratch). This graph's journal title format is `MMM do, yyyy` (e.g. `"Sep 17th, 2026"` — check with `show --graph notes --page "Journal"` if it's ever unclear or changed).
- "Update my <topic> cheat sheet" / "add this to my notes" → find or create the relevant page (`search page`, `list page`), then `upsert block --target-page "<page>" --blocks-file <file>` for multi-block content, or `upsert block --target-page "<page>" --content "..."` for a single line.
- Prefer a real `--blocks-file` (EDN) for anything with structure (multiple bullets, nested steps, code blocks) rather than flattening into one `--content` string — see "Structured block writes" below.
- When content includes literal `[[...]]`-looking text that is not meant to be a page reference (e.g. shell `[[ test ]]` syntax inside a code sample), break the bracket pairing (e.g. insert a zero-width space) rather than leaving it verbatim — the CLI eagerly resolves every `[[...]]` as a page link wherever it appears in a block's text, including inside code fences, and will error if the bracketed text contains a "/".

## Quick start

- Run `logseq --help` to see top-level commands and global flags.
- Run `logseq <command> --help` to see command-specific options.
- Use `--graph` to target a specific graph.
- Omit `--output` for human output. Set `--output json` or `--output edn` only when machine-readable output is required.

## Command groups (from `logseq --help`)

- Graph Inspect and Edit:
- `list node`, `list page`, `list tag`, `list property`, `list task`, `list asset`
- `upsert block`, `upsert page`, `upsert tag`, `upsert property`, `upsert task`, `upsert asset`
- `remove block`, `remove page`, `remove tag`, `remove property`
- `query`, `query list`, `show`, `search block|page|property|tag`
- Graph Management:
- `graph list|create|switch|remove|validate|info|export|import|backup list|backup create|backup restore|backup remove`
- `server list|cleanup|start|stop|restart`
- `doctor`
- `sync status|start|stop|upload|download|remote-graphs|ensure-keys|grant-access|config set|get|unset`
- Authentication: `login|logout`
- Utilities: `agent bridge`, `completion`, `debug`, `example`, `skill`

## Global options

- `--config` Path to `cli.edn` (default `<root-dir>/cli.edn`)
- `--graph` Graph name
- `--root-dir` Path to CLI root dir (default `~/logseq`)
- `--timeout-ms` Request timeout in ms (default `10000`)
- `--output` Output format (`human`, `json`, `edn`)
- `--profile` Enable stage timing profile output to stderr
- `--verbose` Enable verbose debug logging to stderr

## Command option policy

- Do not memorize or hardcode command options in this skill.
- Before running any command, always check live options with:
- `logseq <command> --help`
- `logseq <command> <subcommand> --help`

## Task command preference

- If a user request is task-related, prefer task-scoped commands first.
- Use `list task`, `upsert task`, and other `... task` commands before block/page-level alternatives.
- Only fall back to `upsert block`/`list page` style workflows when task commands cannot satisfy the requested operation.
- For any task state, create/update the task with `upsert task --status <status>` and keep status markers out of `--content`.
- If the same task block also needs additional tags, use explicit tag association separately, for example `upsert block --id <task-block-id> --update-tags '["AI-GENERATED" "CLI"]'`.

## Examples policy

- Do not maintain long static command examples in this skill.
- Use `logseq example` as the source of truth for runnable examples.
- Before proposing runnable commands, always inspect live examples with:
  - `logseq example`
  - `logseq example <command-or-prefix...>`
  - `logseq example <command-or-prefix...> --help`
- Prefer exact selectors when possible (for example, `logseq example upsert page`).
- Use prefix selectors when grouped examples are needed (for example, `logseq example upsert`).
- Replace placeholder ids/uuids in retrieved examples with real entities from the target graph.
- Use `logseq list ...`, `logseq show ...`, or `logseq query ...` first to discover valid ids/uuids.
- For graph transfer flows, keep `graph export --file` and `graph import --input` paths consistent.
- Quote `--content` values with single quotes in shell examples, for example `--content 'Block content'`, so markdown backticks are not interpreted by the shell.

## Structured block writes

- When writing multi-item or hierarchical content, prefer a block tree instead of packing everything into one block.
- Preserve the source structure as sibling and child blocks. Each logical bullet, row, or subsection should usually become its own block.
- Reserve `--content` for true single-block writes or targeted updates to one existing block.
- If the user asks to write notes, lists, outlines, imported data, or any content that already has structure, do not flatten it into one long `--content` string.

## Tag association semantics

- For block or page tag association, prefer explicit CLI tag options such as `--update-tags` and `--remove-tags`.
- `upsert block` supports `--update-tags` in both create mode and update mode.
- `--update-tags` expects an EDN vector.
- Tag values may be tag title/name strings, db/id, UUID, or `:db/ident` values.
- String tag values may include a leading `#`, but they should still be passed inside `--update-tags`.
- If the user asks to tag a block or page, prefer explicit tag association.
- Tags must already exist and be public. If needed, create the tag first with `upsert tag --name "<TagName>"`.

## Anti-patterns and correct usage

### Task status in block content

- Anti-pattern: store task state in content, for example `--content 'DONE Implemented and verified ...'` with `upsert block`.
- Correct usage: store task state as structured task data with `upsert task --status <status>` and keep content free of `TODO`, `DOING`, `DONE`, or other status markers.
- Example:
  1. `logseq upsert task --graph "Lambda RTC" --target-page "May 4th, 2026" --content 'Some content here' --status done --output json`
  2. If tags are needed, use the returned block id: `logseq upsert block --graph "Lambda RTC" --id <returned-block-id> --update-tags '["AI-GENERATED" "CLI" "db-sync"]'`

### Hashtags in content instead of tag association

- Anti-pattern: treat content hashtags as tag association, for example `--content 'Summary #AI-GENERATED'`.
- Correct usage: keep tags in explicit tag options, for example `upsert block --update-tags '["AI-GENERATED"]'`.

### Comma-separated tag lists

- Anti-pattern: pass tag updates as a comma-separated string, for example `--update-tags "AI-GENERATED,CLI"`.
- Correct usage: pass an EDN vector, for example `--update-tags '["AI-GENERATED" "CLI"]'`.

### Missing or private tags

- Anti-pattern: retry the same tag association command after a tag association failure without checking tag state.
- Correct usage: verify the tag exists and is public; create it first when needed with `upsert tag --name "<TagName>"`.

## Stop hook: session-log prompt

This workstation has a Claude Code **Stop hook** wired in `~/.claude/settings.json` that fires when a session ends. It does *not* write to Logseq itself — an LLM can't reliably tell trivial edits from things worth journaling, so it defers to the user.

- Script: `hooks/logseq-stop-log.sh` in this repo, installed at `~/.claude/hooks/logseq-stop-log.sh`.
- Behavior: once per session, if any tool was used, it blocks the Stop (`{"decision":"block","reason":...}`) so the assistant asks the user (via `AskUserQuestion`) whether to log a note to today's journal page, and what to write. Declining or "skip" ends it there — nothing is written without explicit go-ahead.
- Dedup: touches a marker file at `~/.cache/claude-code-logseq-stop/<session_id>` so it only blocks once per session (also checks the hook's own `stop_hook_active` flag to avoid looping).

Install on a new machine:

```sh
mkdir -p ~/.claude/hooks
cp hooks/logseq-stop-log.sh ~/.claude/hooks/logseq-stop-log.sh
chmod +x ~/.claude/hooks/logseq-stop-log.sh
```

Then merge this into `~/.claude/settings.json` (merge into existing `hooks.Stop`, don't overwrite):

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/logseq-stop-log.sh", "timeout": 15 }
        ]
      }
    ]
  }
}
```

Needs `jq` on PATH. Requires opening `/hooks` once (or restarting Claude Code) after first install so the settings watcher picks up the new hooks directory.

## Tips

- `query list` returns both built-ins and `custom-queries` from `cli.edn`.
- `agent bridge` starts/reuses db-worker-node, listens to db-worker-node events, scans routable tasks on startup and each event, starts one in-process master Codex session, and dispatches matched task/comment requests to that session.
- `show --id` accepts either one db/id or an EDN vector of ids.
- `remove block --id` also accepts one db/id or an EDN vector.
- `upsert block` enters update mode when `--id` or `--uuid` is provided.
- Always verify command flags with `logseq --help` and `logseq <...> --help` before execution.
- If `logseq` reports that it doesn’t have read/write permission for `root-dir`, then check filesystem permissions or set `LOGSEQ_CLI_ROOT_DIR`.
- In sandboxed environments, `graph create` may print a process-scan warning to stderr; if command status is `ok`, the graph is still created.
