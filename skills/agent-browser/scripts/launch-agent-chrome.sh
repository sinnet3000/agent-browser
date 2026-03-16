#!/usr/bin/env bash
# Launch Chrome with the agent profile at ~/.agent-chrome with remote debugging.
# Chrome's default data dir blocks remote debugging, so we use a dedicated path.
# Safe to run multiple times -- exits early if already running.

set -euo pipefail

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PROFILE_DIR="$HOME/.agent-chrome"
DEBUG_PORT=9222

# Already running?
if curl -sf "http://localhost:${DEBUG_PORT}/json/version" >/dev/null 2>&1; then
  echo "Chrome agent profile is already running on port ${DEBUG_PORT}."
  exit 0
fi

echo "Launching Chrome (agent profile at ${PROFILE_DIR}) on port ${DEBUG_PORT}..."

"$CHROME" \
  --user-data-dir="$PROFILE_DIR" \
  --remote-debugging-port=$DEBUG_PORT \
  --no-first-run \
  --no-default-browser-check \
  &>/dev/null &

# Wait up to 10 seconds.
for i in $(seq 1 20); do
  if curl -sf "http://localhost:${DEBUG_PORT}/json/version" >/dev/null 2>&1; then
    echo "Chrome ready on port ${DEBUG_PORT}."
    exit 0
  fi
  sleep 0.5
done

echo "ERROR: Chrome did not start in time on port ${DEBUG_PORT}." >&2
exit 1
