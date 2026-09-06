#!/usr/bin/env bash

set -u

PROJECT_DIR="$(git rev-parse --show-toplevel)"
TASK_FILE="$PROJECT_DIR/automation/task.md"
LOG_DIR="$PROJECT_DIR/automation/logs"

mkdir -p "$LOG_DIR"

TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
LOG_FILE="$LOG_DIR/run_$TIMESTAMP.log"

cd "$PROJECT_DIR" || exit 1

echo "======================================" | tee -a "$LOG_FILE"
echo "Codex Auto Runner" | tee -a "$LOG_FILE"
echo "Started: $(date)" | tee -a "$LOG_FILE"
echo "Project: $PROJECT_DIR" | tee -a "$LOG_FILE"
echo "======================================" | tee -a "$LOG_FILE"

if [ ! -f "$TASK_FILE" ]; then
    echo "ERROR: automation/task.md not found." | tee -a "$LOG_FILE"
    exit 1
fi

PROMPT="
Read automation/task.md first.

Work on the Current Task described there.

Rules:
- Continue from the current repository state.
- Do not repeat items already listed as completed.
- Work autonomously on the next unfinished step.
- Inspect existing files before changing them.
- Test your changes when appropriate.
- Before finishing, update automation/task.md with:
  1. what you completed,
  2. the current status,
  3. the next unfinished step.
- Do not delete unrelated user files.
"

echo "Starting Codex..." | tee -a "$LOG_FILE"

codex exec "$PROMPT" 2>&1 | tee -a "$LOG_FILE"

CODEX_EXIT=${PIPESTATUS[0]}

echo "" | tee -a "$LOG_FILE"
echo "Codex exited with code: $CODEX_EXIT" | tee -a "$LOG_FILE"
echo "Finished: $(date)" | tee -a "$LOG_FILE"

echo "Saving repository state to GitHub..." | tee -a "$LOG_FILE"

"$PROJECT_DIR/scripts/autopush.sh" 2>&1 | tee -a "$LOG_FILE"

exit "$CODEX_EXIT"
