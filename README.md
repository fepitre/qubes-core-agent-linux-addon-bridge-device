# qubes-core-agent-linux-addon-bridge-device

Agent-side component of the Qubes OS bridge device addon.  Install this in
any backend qube whose bridge interfaces you want to expose to other qubes as
attachable network devices.

For the dom0/adminvm side see
[qubes-core-admin-addon-bridge-device](https://github.com/QubesOS/qubes-core-admin-addon-bridge-device).

## How it works

The package installs `/usr/lib/qubes/publish-bridge`, a NetworkManager
dispatcher script that writes bridge metadata into QubesDB:

```
/qubes-bridge-devices/<bridge-name>/desc   "<name> (bridge_ports: <p1> <p2> ...)"
```

dom0 watches these keys and presents each bridge as a `bridge`-class device
via `admin.vm.device.bridge.Available`.

### NM dispatcher events handled

The script is installed as a non-blocking NM dispatcher
(`no-wait.d/qubes-bridge`) so it never delays network operations.

| NM action   | `$DEVICE_IFACE` | `$MASTER_IFACE` | Effect |
|-------------|-----------------|-----------------|--------|
| `up`        | the bridge      | (none)          | Publish bridge with current port list |
| `pre-down`  | the bridge      | (none)          | Unpublish bridge before it disappears |
| `slave-up`  | enslaved port   | the bridge      | Re-publish bridge to update port list |
| `slave-down`| released port   | the bridge      | Re-publish bridge to update port list |

### Boot-time publishing

`qubes-publish-bridges.service` (systemd, one-shot) calls
`publish-bridge --all` after `network.target` to catch bridges that exist
at boot before NetworkManager activates them (e.g. bridges created by other
systemd services or persistent kernel configurations).
