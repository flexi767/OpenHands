#!/bin/bash
set -euo pipefail
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
set -a
source "$HOME/openhands/service.env"
set +a
cd "$HOME/openhands"
exec node "$HOME/openhands/source/bin/agent-canvas.mjs" --public --host 127.0.0.1 --port 48080 ${OPENHANDS_MODE:-}
