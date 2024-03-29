{
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "wofi --allow-images --allow-markup --insensitive --gtk-dark --columns=1 --width=15% --show=drun";
      bars = [];
    };
    extraConfig = ''
      input "type:keyboard" {
        xkb_options ctrl:nocaps
        xkb_numlock enable
        repeat_delay 200
        repeat_rate 30
      }

      input "type:pointer" {
        natural_scroll enabled
      }

      input "type:touchpad" {
        natural_scroll enabled
        tap enabled
      }

      bar {
        swaybar_command waybar
      }

      font pango:Open Sans 12

      seat seat0 xcursor_theme Vanilla-DMZ 32

      exec_always {
        gsettings set org.gnome.desktop.interface cursor-theme Vanilla-DMZ
        gsettings set org.gnome.desktop.interface cursor-size 32
      }

      output DP-1 mode 3840x2160@59.997Hz scale 2

      # laptop displays
      output DP-2 mode 3840x2160@59.997Hz scale 2
      output eDP-1 mode 1920x1080@60.002Hz scale 1.25

      exec mkfifo $SWAYSOCK.wob && tail -f $SWAYSOCK.wob | wob

      # Monitor brightness
      bindsym XF86MonBrightnessDown exec brightnessctl set 10%- | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > $SWAYSOCK.wob
      bindsym XF86MonBrightnessUp exec brightnessctl set +10% | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > $SWAYSOCK.wob

      # Audio playback controls
      bindsym XF86AudioPrev exec playerctl previous
      bindsym XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next

      # Volume toggles
      bindsym XF86AudioMute exec pamixer --toggle-mute && ( pamixer --get-mute && echo 0 > $SWAYSOCK.wob ) || pamixer --get-volume > $SWAYSOCK.wob
      bindsym XF86AudioLowerVolume exec pamixer -ud 5 && pamixer --get-volume > $SWAYSOCK.wob
      bindsym XF86AudioRaiseVolume exec pamixer -ui 5 && pamixer --get-volume > $SWAYSOCK.wob

      # Screenshots
      bindsym Mod4+Ctrl+4 exec grimshot save area

      set $lock_path '~/.config/sway/lock.sh'
      set $idle_path '~/.config/sway/idle.sh'

      # Lock Button
      bindsym Mod4+Control+q exec $lock_path

      # Clear Mako notifications
      bindsym Mod4+c exec makoctl dismiss --all

      exec $idle_path

      workspace 1
      exec swaymsg "layout tabbed"
      exec alacritty
      exec swaymsg "split horizontal"
      exec alacritty

      workspace 2
      workspace_layout tabbed
      exec firefox
    '';
  };
}
