#!/usr/bin/env bash

set -e -o pipefail

echo
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

echo
echo 'Installing systemd-backup'
${PERMISSION} cp backup ${BASE_BIN}
${PERMISSION} cp backup-wait ${BASE_BIN}
cp backup.service ${HOME}/.config/systemd/user/
cp backup.timer ${HOME}/.config/systemd/user/

set +e
set +o pipefail

mkdir -p ${HOME}/.config/systemd-backup/

cp -n backup.json ${HOME}/.config/systemd-backup/ 2>/dev/null
cp -n exclude ${HOME}/.config/systemd-backup/ 2>/dev/null
touch ${HOME}/.config/systemd-backup/.secret

systemctl --user daemon-reload

echo
echo 'systemd-backup installed!'
echo
echo 'To activate execute `systemctl --user enable --now backup.timer`'
