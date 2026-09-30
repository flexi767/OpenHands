# J main host with M3 and M5 satellites

Installed 2026-09-30 from this fork, upstream source `1.24.0`; Agent Server
`1.50.1`, automation `1.16.0`, Codex ACP `2.0.1`.

J runs Canvas, Agent Server and automation. M3/M5 run Agent Server and automation
with `--backend-only`. Each has an active `codex` agent profile using its own
existing ChatGPT login. These are host processes with the deployment user's
filesystem permissions. Workspaces and persistent state are separate per host.

## Access

Run `bash deploy/j-m3-m5/connect.sh` on the client and open
<http://127.0.0.1:48180>. The configured browser has J Main, M3 Satellite and
M5 Satellite registered; choose one in the backend switcher. On a new browser,
add J at `http://127.0.0.1:48180`, M3 at `http://127.0.0.1:48184`, and M5 at
`http://127.0.0.1:48185`. Obtain each key privately from that host's
`~/openhands/service.env`; do not paste it into chat, source control, or logs.
Keep the client tunnel running. Satellite backends are independent execution
hosts; this does not automatically distribute one conversation across hosts.

## Layout and services

Every host has `~/openhands/source` (fork checkout), `~/openhands/start.sh`,
`~/openhands/service.env` (mode 0600, independent session/encryption keys),
and `~/openhands/state/agent-canvas`. Install dependencies with `npm ci
--ignore-scripts`; build J's frontend with `npm run build`. Source config/defaults.json
owns SDK and automation pins. The older npm release remains in `runtime/`
but services execute `source/bin/agent-canvas.mjs`.

J has enabled systemd user services `openhands`, `openhands-m3`, `openhands-m5`,
with user linger enabled. `systemctl --user status openhands` and
`journalctl --user -u openhands` show runtime status. The two satellite services
are SSH tunnels: J loopback 48084 -> M3 loopback 48080 and J loopback 48085 ->
M5 loopback 48080. J uses a dedicated `~/openhands/satellite_key`, restricted on
satellites to forwarding to 127.0.0.1:48080. Its known-hosts file is separate
from the user's SSH trust file. M5 uses its LAN address 192.168.1.223 through J's
existing wg-lan route because the DNS address was unreachable during setup.

Mac satellites use `~/Library/LaunchAgents/dev.openhands.satellite.plist`, with
RunAtLoad/KeepAlive. They start in the user's GUI login session; log in after a
reboot. Logs are in `~/openhands/logs/`. Inspect with
`launchctl print gui/$(id -u)/dev.openhands.satellite`. A controlled restart is
`launchctl kickstart -k gui/$(id -u)/dev.openhands.satellite`.

All ingress services bind explicitly to 127.0.0.1:48080; Agent Server and automation
use loopback 48081/48082. J's static frontend is loopback 48083. Public auth mode
prevents injecting session keys into served frontend assets. The client tunnel
uses 48180/48184/48185 to avoid colliding when the client is also a satellite.
No public endpoint or production application configuration was added.

## Verification and recovery

All three authenticated settings APIs returned 200. All three executed a Codex
conversation whose final response was `OPENHANDS_READY`. Canvas showed all three
backends Connected. J's production frontend build completed successfully.

If a satellite is unavailable, inspect its LaunchAgent and J's matching tunnel
service. If credentials expire, run `codex login` on that host. Preserve
`service.env` and state when updating source; encryption keys must stay stable.
Update deliberately: fetch/pull the fork, install from the lockfile, build J,
then restart the affected services and verify health plus an authenticated API.

To stop deployment, disable J's three user units and boot out each Mac LaunchAgent.
Do not delete state or credential files as part of service shutdown.
