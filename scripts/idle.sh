#!/bin/sh

# Intended order of events for handling idle behavior depending on
# whether the machine was manually locked or not.

swayidle -w \
  timeout 180 'if ! pgrep swaylock > /dev/null; then exec ~/.config/sway/lock.sh; fi' \
  timeout 300 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
  timeout 420 'systemctl suspend' \
  before-sleep 'swaymsg "output * power off"' \
  before-sleep 'playerctl status --no-messages && playerctl pause --no-messages' \
  before-sleep 'if ! pgrep swaylock > /dev/null; then exec ~/.config/sway/lock.sh; fi' \
  after-resume 'swaymsg "output * power on"'
