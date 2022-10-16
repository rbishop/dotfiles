{ settings, ... }:

{
  programs.waybar = {
    enable = true;

    settings = [{
      layer = "bottom";
      position = "top";
      height = 30;
      spacing = 4;

      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = settings.waybar-order;
      modules = {
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

        "network#1" = {
          interval = 1;
          interface = "eth0";
          format-ethernet = "";
          format-disconnected = "";
          tooltip = true;
          tooltip-format-ethernet = ''
            {ipaddr}/{cidr}
             {bandwidthDownBits}
             {bandwidthUpBits}'';
        };

        "network#2" = {
          interval = 1;
          interface = "wlan0";
          format-wifi = "";
          on-click = "if [[ $(nmcli radio wifi) == \"enabled\" ]]; then nmcli radio wifi off; else nmcli radio wifi on; fi";
          format-disconnected = "";
          tooltip = true;
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

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
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
          format = "<b>{:%I:%M %p}</b>";
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
