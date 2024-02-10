{ settings, ... }:

{
  programs.waybar = {
    enable = true;

    settings = [{
      layer = "bottom";
      position = "top";
      height = 30;
      spacing = 4;

      modules-left = [ "custom/power" "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = settings.waybar-order;
      modules = {
        "custom/power" = {
          format = " ";
          on-click = "/home/${settings.username}/.config/sway/power.sh";
        };

        "cpu" = {
          format = "{usage}% ";
          interval = 1;
          tooltip = true;
        };

        "temperature" = {
          interval = 2;
          hwmon-path-abs = settings.sensors.cpu_temp;
          input-filename = "temp1_input";
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        "network#1" = {
          interval = 2;
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
          format = "";
          format-wifi = "";
          on-click = "iwgtk";
          format-disconnected = "";
          format-disabled = "";
          format-icons = [];
          tooltip = true;
          tooltip-format-wifi = ''
            {essid} {frequency}Ghz
            {ipaddr}/{cidr}
            {signalStrength}   
            {signaldBm} db
             {bandwidthDownBits}
             {bandwidthUpBits}'';
        };

        "bluetooth" = {
          format-connected = "  ";
          format-on = "  ";
          format-off = "off";
          format-disabled = "down";
          tooltip-format = "{status}";
          on-click = "blueman-manager";
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
          bat = settings.sensors.battery;
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
