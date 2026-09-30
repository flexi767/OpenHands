#!/bin/bash
set -euo pipefail
exec ssh -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=20 -o ServerAliveCountMax=3 \
  -L 127.0.0.1:48180:127.0.0.1:48080 \
  -L 127.0.0.1:48184:127.0.0.1:48084 \
  -L 127.0.0.1:48185:127.0.0.1:48085 j
