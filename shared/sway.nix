{ pkgs, ...} : {
  wayland.windowManager.sway = rec {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "wofi --allow-images --allow-markup --insensitive --gtk-dark --columns=1 --width=15% --show=drun";
      bars = [];
      keybindings = pkgs.lib.mkOptionDefault {
        "${config.modifier}+space" =  "exec wofi --allow-images --allow-markup --insensitive --gtk-dark --columns=1 --width=15% --show=drun";
      };
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

      set $mod ${config.modifier}
      set $gnome-schema org.gnome.desktop.interface
      set $cursor_theme Vanilla-DMZ
      set $cursor_size 24

      ### Xcursor configuration
      seat seat0 xcursor_theme $cursor_theme $cursor_size
      exec_always {
        gsettings set $gnome-schema icon-theme $cursor_theme
        gsettings set $gnome-schema cursor-theme $cursor_theme
        gsettings set $gnome-schema cursor-size $cursor_size
      }

      # External monitor
      output 'BNQ BenQ RD280U D4R0015401Q' mode 3840x2560@59.984Hz scale 2

      # Laptop displays
      output "BOE 0x091D Unknown" mode 1920x1080@60.002Hz scale 1.25
      output "BOE 0x0BCA Unknown" mode 2256x1504@59.999Hz scale 1.5

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
      bindsym $mod+Ctrl+4 exec grimshot save area

      set $lock_path '~/.config/sway/lock.sh'
      set $idle_path '~/.config/sway/idle.sh'

      # Lock Button
      bindsym $mod+Control+q exec $lock_path

      # Clear Mako notifications
      bindsym $mod+c exec makoctl dismiss --all

      # Wofi Menu
      #bindsym $mod+space exec wofi --allow-images --allow-markup --insensitive --gtk-dark --columns=1 --width=15% --show=drun

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
