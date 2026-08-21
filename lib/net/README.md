# lib/net

Network: SSH config parsing and remoting, socket listings, HTTP, netcat, proxy,
self-signed certs.

```nu
use lib/net *
```

## Commands

| Command                       | From          | Does                                                       |
| ----------------------------- | ------------- | ---------------------------------------------------------- |
| `ssh <host> <cmd>`            | `remoting.nu` | Run Nushell commands on a predefined host and parse the result locally |
| `ssh script`                  | `remoting.nu` | Same, but sends a Nu script with arguments                 |
| `wake <host>`                 | `remoting.nu` | Wake-on-LAN                                                |
| `scp <lhs> <rhs>`             | `ssh.nu`      | `scp -r` with host completions on both sides               |
| `ssh-list`                    | `ssh.nu`      | Every `Host` entry found under `~/.ssh`, as a table        |
| `parse-ssh-file`              | `ssh.nu`      | Parse one ssh config file into records                     |
| `sockets` (`main`)            | `sockets.nu`  | `lsof -i` parsed into a table; `-j` abbreviates Java classpaths |
| `java-cmd classpath`          | `sockets.nu`  | Classpath of a running Java process                        |
| `java-cmd abbreviate-classpath` | `sockets.nu`| Shorten a classpath for display                            |
| `ns`                          | `network.nu`  | `netstat -aplnetu` parsed into a table                     |
| `ip-route`                    | `network.nu`  | `ip route` parsed into a table                             |
| `curls <host>`                | `network.nu`  | Curl a host, `--port` defaults to 443                      |
| `site-mirror <url>`           | `network.nu`  | Alias: `wget -m -k -E -p -np -e robots=off`                |
| `common-ips`                  | `proxy.nu`    | Loopback / gateway / LAN addresses, derived from `ip-route`|
| `toggle proxy`                | `proxy.nu`    | Turn proxy env vars on and off                             |
| `selfsigned-certificate`      | `ssl.nu`      | Generate a self-signed cert                                |
| `reverse-shell <host:port>`   | `netcat.nu`   | Build a `bash -i >& /dev/tcp/...` reverse shell; `-p` prints instead of running |
| `serve-shell <port>`          | `netcat.nu`   | Listen with `ncat`/`nc`, whichever is installed            |

## Two things named `ssh`

`remoting.nu` defines a real command `ssh` (run Nu remotely), while `ssh.nu`
declares `export extern main` — a signature for the *external* `ssh` binary,
which exists to give it completions.

`mod.nu` glob-imports both, so loading the category gives you `remoting.nu`'s
`ssh` plus a bare `main` extern from `ssh.nu`. If completions on the real `ssh`
are what you want, load that file on its own:

```nu
use lib/net/ssh.nu      # `ssh` = the external binary, with completions
```

This overlap is a known rough edge and hasn't been verified against a live
Nushell in this repo's docs — if `ssh` resolves to the wrong thing after
`use lib/net *`, that is why.

## Not re-exported by `mod.nu`

| File                     | Why                                  | Use                                   |
| ------------------------ | ------------------------------------ | ------------------------------------- |
| `simple_http_request.nu` | Script — bare pipeline, not a module | `use lib/net/simple_http_request.nu`  |

## Two `main`s in one module

`sockets.nu` and `ssh.nu` (the latter an `export extern`) both carry `export def main`, and `mod.nu` glob-imports both. Whether
that resolves cleanly, last-wins, or errors has not been verified against a
live Nushell. If `sockets` / `ssh` misbehave after `use lib/net *`, load the file
directly instead — that path is unambiguous.

## Requires

External tools, per command: `lsof`, `netstat`, `awk`, `ip`, `wget`, `curl`,
`openssl`, and `ncat` or `nc`. Most of these are Linux-shaped — `ns` parses
GNU `netstat` output specifically.
