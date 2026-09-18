#!/usr/bin/env bash
# Stop hook: don't auto-write to Logseq (LLM can't reliably judge trivial vs. worth-logging).
# Instead, once per session, if any tool was used, block the stop so the assistant
# asks the human whether/what to log. ponytail: gate is "any tool call happened" —
# cheapest signal that distinguishes a real session from a one-line Q&A, nothing fancier.
set -euo pipefail

input="$(cat)"
session_id="$(jq -r '.session_id // empty' <<<"$input")"
transcript="$(jq -r '.transcript_path // empty' <<<"$input")"
stop_hook_active="$(jq -r '.stop_hook_active // false' <<<"$input")"

[ -n "$session_id" ] && [ -n "$transcript" ] && [ -f "$transcript" ] || exit 0
[ "$stop_hook_active" = "true" ] && exit 0

marker_dir="$HOME/.cache/claude-code-logseq-stop"
marker="$marker_dir/$session_id"
[ -f "$marker" ] && exit 0

tool_calls="$(jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | .name' "$transcript" 2>/dev/null)"
[ -n "$tool_calls" ] || exit 0

files="$(jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and (.name=="Write" or .name=="Edit")) | .input.file_path' "$transcript" 2>/dev/null | sort -u)"

mkdir -p "$marker_dir"
touch "$marker"

day="$(date +%-d)"
case "$day" in
  1|21|31) suffix=st ;;
  2|22) suffix=nd ;;
  3|23) suffix=rd ;;
  *) suffix=th ;;
esac
page="$(date +%b) ${day}${suffix}, $(date +%Y)"

if [ -n "$files" ]; then
  files_note="Files touched: $(paste -sd', ' <<<"$files")."
else
  files_note="No files touched (tool calls only, e.g. research/investigation)."
fi

reason=$(cat <<EOF
This session used tools. $files_note
Ask the user (AskUserQuestion) whether to add a note to today's Logseq journal page "$page", offering: skip (trivial), or log with a short summary they confirm/edit. Do not decide trivial-vs-worth-logging yourself, and do not write to Logseq without their explicit go-ahead. Match the terse personal-shorthand style from the logseq-cli skill (SKILL.md) if they say yes.
EOF
)

jq -n --arg reason "$reason" '{"decision":"block","reason":$reason}'
