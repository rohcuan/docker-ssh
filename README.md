# docker-ssh

Runs an SSH server on Docker Swarm using a Debian Toolbx 12 container.

## Credentials

| User     | Password | Sudo  |
|----------|----------|-------|
| `user`   | `user`   | Yes, no password prompt |

## Deploy

Requires a Swarm cluster (run `docker swarm init` if you don't have one).

```bash
docker stack deploy -c docker-stack.yml ssh
```

## SSH into it

The SSH port is published on host port **2222**.

```bash
ssh user@localhost -p 2222
# password: user
```

From another machine, replace `localhost` with your host's address.

Once logged in as `user`, run `sudo` freely — it never asks for a password.

## Files

- `docker-stack.yml` — Swarm stack definition (service, image, port, entrypoint)
- `entrypoint.sh` — container startup script: installs OpenSSH + sudo, creates the `user`, configures passwordless sudo, and starts `sshd`

## How it works

`docker-stack.yml` sets `entrypoint: ["/entrypoint.sh"]` and volume-mounts `./entrypoint.sh` so the script hands control to itself at container start. On each start it ensures SSH and sudo are installed and the `user` account exists.

## Tear down

```bash
docker stack rm ssh
```
