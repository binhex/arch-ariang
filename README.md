# Application

[AriaNg](https://github.com/mayswind/ariang)

## Description

AriaNg is a modern web frontend making aria2 easier to use. AriaNg is written
in pure html & javascript, thus it does not need any compilers or runtime
environment. You can just put AriaNg in your web server and open it in your
browser. AriaNg uses responsive layout, and supports any desktop or mobile
devices.

## Build notes

Latest commit to GitHub branch 'master'.

## Usage

```bash
docker run -d \
    --name=<container name> \
    -p <host port for ariang>:8127 \
    -p <host port for aria>:6800 \
    -v <path for config files>:/config \
    -v <path for data files>:/data \
    -v /etc/localtime:/etc/localtime:ro \
    -e TZ=Etc/<region> \
    -e ARIA2_RPC_SECRET=<rpc secret token> \
    -e ENABLE_STARTUP_SCRIPTS=<yes|no> \
    -e STARTUP_SCRIPTS_MODE=<wait|parallel> \
    -e HEALTHCHECK_COMMAND=<command> \
    -e HEALTHCHECK_ACTION=<action> \
    -e HEALTHCHECK_HOSTNAME=<hostname> \
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    binhex/arch-ariang
```

Please replace all user variables in the above command defined by <> with the
correct values.

## Access AriaNg Web UI

`http://<host ip>:8127`

## Aria2 RPC Credentials

AriaNg has no login of its own, access to aria2 is controlled by the JSON-RPC
secret token. If `ARIA2_RPC_SECRET` is not set and no secret file exists then a
32 character secret is generated on start and stored in
`/config/aria2/secrets/rpc-secret`, the same secret is reused on every restart.

To connect, open AriaNg, go to `Settings -> RPC`, set the host to your unRAID
host IP, the port to `6800` and paste the secret into `Secret token`.

A `rpc-secret` already set in `/config/aria2/configs/aria2.conf` is used as-is
and no secret file is generated.

## Example

```bash
docker run -d \
    --name=ariang \
    -p 8127:8127 \
    -p 6800:6800 \
    -v /apps/docker/ariang/config:/config \
    -v /apps/docker/ariang/data:/data \
    -v /etc/localtime:/etc/localtime:ro \
    -e TZ=Etc/UTC \
    -e ENABLE_STARTUP_SCRIPTS=no \
    -e STARTUP_SCRIPTS_MODE=wait \
    -e UMASK=000 \
    -e PUID=99 \
    -e PGID=100 \
    binhex/arch-ariang
```

## Notes

`ARIA2_RPC_SECRET` sets the aria2 JSON-RPC secret token, it takes precedence
over a secret stored in `/config/aria2/secrets/rpc-secret` and any
`rpc-secret` set in `/config/aria2/configs/aria2.conf`.

`/data` is available as a download location, aria2 writes to
`/config/aria2/downloads` by default, change the `dir` option in
`/config/aria2/configs/aria2.conf` to use `/data` instead.

`ENABLE_STARTUP_SCRIPTS` when set to `yes` (default `no`) will allow a user to
install additional packages from the official Arch Repository or the Arch User
Repository (AUR) via scripts located in the folder `/config/ariang/scripts/`.

`STARTUP_SCRIPTS_MODE` controls how those scripts are executed, set to `wait`
(default) to run each script in turn and wait for it to complete before the next
script runs, or `parallel` to run all scripts at the same time.

User ID (PUID) and Group ID (PGID) can be found by issuing the following command
for the user you want to run the container as:-

```bsh
id <username>

```

___
If you appreciate my work, then please consider buying me a beer  :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MM5E27UX6AUU4)

[Documentation](https://github.com/binhex/documentation) | [Support forum](https://forums.unraid.net/topic/124948-support-binhex-ariang/)
