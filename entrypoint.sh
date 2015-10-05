#!/bin/bash
set -e

USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}

install_skype() {
  echo "Installing skype-wrapper..."
  install -m 0755 /var/cache/skype/skype-wrapper /target/
  echo "Installing skype..."
  ln -sf skype-wrapper /target/skype
}

uninstall_skype() {
  echo "Uninstalling skype-wrapper..."
  rm -rf /target/skype-wrapper
  echo "Uninstalling skype..."
  rm -rf /target/skype
}

create_user() {
  # create group with USER_GID
  if ! getent group ${SKYPE_USER} >/dev/null; then
    groupadd -f -g ${USER_GID} ${SKYPE_USER} >/dev/null 2>&1
  fi

  # create user with USER_UID
  if ! getent passwd ${SKYPE_USER} >/dev/null; then
    adduser -c 'docker skype user' --uid ${USER_UID} --gid ${USER_GID} ${SKYPE_USER} >/dev/null 2>&1
  fi
  chown ${SKYPE_USER}:${SKYPE_USER} -R /home/${SKYPE_USER}
}

grant_access_to_video_devices() {
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      break
    fi
  done

  if [[ -n $VIDEO_GID ]]; then
    usermod -a -G $VIDEO_GID ${SKYPE_USER}
  fi
}

launch_skype() {
  cd /home/${SKYPE_USER}
  exec sudo -HEu ${SKYPE_USER} PULSE_SERVER=/run/pulse/native QT_GRAPHICSSYSTEM="native" $@
}

case "$1" in
  install)
    install_skype
    ;;
  uninstall)
    uninstall_skype
    ;;
  skype)
    create_user
    grant_access_to_video_devices
    launch_skype $@
    ;;
  *)
    exec $@
    ;;
esac
