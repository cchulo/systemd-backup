#!/usr/bin/env bash

set -e -o pipefail

if [[ "$1" == "local" ]]; then
  echo "Installing scripts in ${HOME}/.local"
  BASE_BIN="${HOME}/.local/bin"
  BASE_LIB="${HOME}/.local/lib/"
  PERMISSION=""

  # paths under ~/.local are not standard
  mkdir -p "${BASE_BIN}"
  mkdir -p "${BASE_LIB}"
else
  echo "Installing scripts in /usr/local"
  BASE_BIN="/usr/local/bin"
  BASE_LIB="/usr/local/lib"
  PERMISSION="sudo"
fi

echo 'Installing systemd-backup'
${PERMISSION} cp backup ${BASE_BIN}
cp backup.service ${HOME}/.config/systemd/user/
cp backup.timer ${HOME}/.config/systemd/user/

echo 'systemd-backup installed!'
echo 'to activate execute `systemctl --user enable --now backup.timer`'
