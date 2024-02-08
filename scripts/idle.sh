#!/bin/sh

# Intended order of events for handling idle behavior depending on
# whether the machine was manually locked or not. Note that the swayidle
# script is repetitive due to swayidle's configuration lacking the
# ability compose transitions because shorter duration timeouts only
# trigger iff the duration is longer than the current highest duration
# timeout.
#
# State | 
# ------|----------------------------------------------------------------
#       | Lock =====> Display Off ======> Suspend/Sleep
# Trans | 
#       | Idle ==========================> Lock 
# ------|
# Time  | 0 ------> 60 ------ 120 ----- 240 ----- 300

swayidle -w \
  timeout 60  'if pgrep swaylock > /dev/null; then swaymsg "output * dpms off"; fi' resume 'swaymsg "output * dpms on"' \
  timeout 120 'if pgrep swaylock > /dev/null; then swaymsg "output * dpms off"; fi' resume 'swaymsg "output * dpms on"' \
  timeout 240 'if pgrep swaylock > /dev/null; then systemctl suspend; fi' \
  timeout 300 ~/.config/sway/lock.sh \
  timeout 360 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
  timeout 480 'systemctl suspend' \
  before-sleep 'swaymsg "output * dpms off"' \
  before-sleep 'playerctl status --no-messages && playerctl pause --no-messages' \
  before-sleep 'exec ~/.config/sway/lock.sh' \
  after-resume 'swaymsg "output * dpms on"'
