{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window.startup_mode = "Maximized";
      scrolling.history = 10000;
      live_config_reload = true;

      env.TERM = "xterm-256color";

      font = {
        size = 12.0;
        use_thin_strokes = false;

        normal = {
          family = "Roboto Mono";
          style = "regular";
        };

        bold = {
          family = "Roboto Mono";
          style = "regular";
        };

        italic = {
          family = "Roboto Mono";
          style = "regular";
        };

        bold_italic = {
          family = "Roboto Mono";
          style = "regular";
        };
      };

      command = {
        program = "alacritty";
        args = [ "-e" "zsh" ];
      };

      key_bindings = [
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
        { key = "PageUp"; action = "ScrollPageUp"; }
        { key = "PageDown"; action = "ScrollPageDown"; }
        { key = "Home"; action = "ScrollToTop"; }
        { key = "End"; action = "ScrollToBottom"; }
      ];
    };
  };

  programs.waybar = {
    enable = true;

    settings = [{
      layer = "bottom";
      position = "top";
      height = 30;
      spacing = 4;

      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "memory" "cpu" "temperature" "network" "pulseaudio" "battery" "clock"  ];
      modules = {
        "network" = {
          interval = 3;
          interface = "wlp0s20f3";
          format-ethernet = "  {ipaddr}/{cidr}";
          format-wifi = "";
          format-disconnected = "";
          tooltip = true;
          tooltip-format-ethernet = ''
            {ipaddr}/{cidr}
             {bandwidthDownBits}
             {bandwidthUpBits}'';
          tooltip-format-wifi = ''
            {essid} {frequency}Ghz
            {ipaddr}/{cidr}
            {signalStrength}   
            {signaldBm} db
             {bandwidthDownBits}
             {bandwidthUpBits}'';
        };

        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-muted = "Muted ";
          format-bluetooth = " {volume}% {icon}";
          format-bluetooth-muted = "Muted ";
          format-icons = {
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
          on-click-right = "blueman-manager";
          scroll-step = 5.0;
          tooltip = true;
        };

        "memory" = {
          interval = 3;
          format = "{used:0.1f}G ";
        };

        "cpu" = {
          format = "{usage}% ";
          tooltip = true;
        };

        "temperature" = {
          interval = 3;
          hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        "battery" = {
          bat = "BAT0";
          interval = 60;
          states = {
              warning = 30;
              critical = 15;
          };
          format = "{capacity}% {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          tooltip = true;
        };

        "clock" = {
          format = "<b>{:%-I:%M %p}</b>";
          today-format = "<b><u>{}</u></b>";
          tooltip = true;
          tooltip-format = ''
            <big>{:%a, %B %e %Y}</big>
            <tt><small>{calendar}</small></tt>
          '';
        };
      };
    }];
  };
}
