# systemd-backup

## Description

Simple python wrapper around rsync that backs up directories configured in `backup.json`
It is executed weekly via systemd service

## Requirements
- python3
- rsync
- tar
- gpg

## Installation
1. Clone this project
2. execute `./install.sh`
3. configure `~/.config/systemd-backup/backup.json` (more details below)
4. configure `exclude` (or optionally add `include`)
5. add a passphrase to `~/.config/systemd-backup/.secret`
6. execute `systemctl --user enable --now backup.timer`

### (Optional) Configure remotes with a script
You may be sending backups to a remote server over ssh
In most cases a passphrase-less key should work, but this may not be desired

If your DE uses passphrase manager, such as KWallet with `kssaskpass` and your keys are already have
their passwords managed by KWallet, then you can just create `~/.config/systemd-backup/prepare-remotes.sh` to
ensure keys are added to ssh-agent, an example of this script can look like:

```bash
#!/usr/bin/env bash

# ~/.config/systemd-backup/prepare-remotes.sh

set -e -o pipefail

# enroll all private .ssh keys
add-private-keys() {
  for possiblekey in ${HOME}/.ssh/id_*; do
    if grep -q PRIVATE "${possiblekey}"; then
        ssh-add "${possiblekey}"
    fi
  done
}

if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l > /dev/null || add-private-keys

rsync -zP --progress $1 $2

```

This file is optional, and other passphrase managers can work, but you will have to refer to their docs for
support.

## How to configure backup.json

- `source_paths`: an array of strings that are paths to folders that need to be backed up
- `archive_age_days`: the age of encrypted archives to be kept around (default is 30 days)
- `backup_location`: the local directory where to store backup (uncompressed/unencrypted)
  - it is recommended you use a secondary drive that is encrypted for this purpose
  - archives are stored in `<backup_location>/../archive`, `backup` will routinely check for old archives to delete whenever
  it is executed.
- `backup_remotes`: an array of paths to send encrypted tar.gz.gpg
  - because it uses rsync, it supports ssh paths: `user@host:/path/to/backup`
  - it can also back up to a mounted drive: `/path/to/backup/mount`

## `exclude` (or `include`) file

- credits goes to [rsync-homedir-excludes](https://github.com/rubo77/rsync-homedir-excludes/blob/master/rsync-homedir-excludes.txt)
for inspiration how to format this file as well as serve as a base
- `exclude` file can be used to exclude file paths from rsync
- `include` file can alternatively be used instead to specify to rsync what files to include

For details on how to use these files read `man rsync` `--include-from=FILE` and `--exclude-from=FILE`

## How to run backup automatically
run `systemctl --user enable --now backup.timer`

for now backups run every sunday at midnight on a persistent timer, so if the machine is off on Sunday at midnight
it will execute the next time it is on.

## How to run backup manually

```bash
$ backup --help

Create backups of your linux directories

options:
  -h, --help            show this help message and exit
  --sync-to-backup      Synchronizes directories to backup directory
  --bundle-and-encrypt  Bundles and encrypts the backup directory
  --send-to-remotes     Sends encrypted archive to the backup remotes specified in ~/.config/systemd-backup/backup.json
```

executing `backup` with no arguments is equivalent to

```bash
backup --sync-to-backup
backup --bundle-and-encrypt
backup --send-to-remotes
```

### Note about send to remotes
Warning: because of the nature of rsync and because I want this to be fully automatic, I employ the use of passphrase-less
ssh keys. I have taken precautions, so it's not a concern for me, but this may not be desirable in your situation.

## Update
1. `git pull`
2. `./install.sh`

## TODO
- make encrypting archives optional
- expand CLI options
- include/exclude files per source_path (will be sure to keep it backwards compatible)
- expand systemd options to configure when it should execute
