{ pkgs, ... }:

let
  # Wrap Chromium to enable Wayland and Hardware Acceleration
  chromium-gpu = pkgs.symlinkJoin {
    name = "chromium";
    paths = [ pkgs.chromium ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/chromium \
        --add-flags "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,VaapiVideoDecoder --ozone-platform=wayland --use-gl=egl --ignore-gpu-blocklist --enable-gpu-rasterization --enable-zero-copy"
    '';
  };

  slack-hidpi = pkgs.symlinkJoin {
    name = "slack";
    paths = [ pkgs.slack ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/slack --add-flags "--force-device-scale-factor=1.5"
    '';
  };
  spotify-hidpi = pkgs.symlinkJoin {
    name = "spotify";
    paths = [ pkgs.spotify ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/spotify --add-flags "--force-device-scale-factor=1.5"
    '';
  };

in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "rbishop";
  home.homeDirectory = "/home/rbishop";

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = "sway"; 
    XDG_SESSION_TYPE = "wayland";
    EDITOR = "vim";
    GIT_EDITOR = "vim";
    BUNDLE_DITOR = "vim";
  };

  home.file.".icons/default" = {
    source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ-AA";
  };

  xsession.pointerCursor = {
    name = "Vanilla-DMZ-AA";
    package = pkgs.vanilla-dmz;
    size = 48;
  };

  fonts.fontconfig.enable = true;

  services.blueman-applet.enable = true;
  services.kanshi = {
    enable = true;
    extraConfig = ''
      profile {
        output "eDP-1" disable
        output "DP-2" enable mode 3840x2160@59.997Hz position 0,0 scale 2.000000
      }

      profile {
        output "eDP-1" enable mode 1920x1080@60.002Hz position 0,0 scale 1.25
      }
    '';
  };

  gtk = {
    enable = true;
    font.name = "Open Sans 12";
    font.size = 12;
    theme.name = "Adwaita";
  };

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

  programs.zsh = {
    enable = true;
    autocd = true;
    prezto.enable = true;

    initExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
      fi
    '';
  };

  programs.vim = { 
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-plug ];
    extraConfig = ''
      ${builtins.readFile /home/rbishop/.vimrc}
    '';
  };
  
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 5000;
    keyMode = "vi";
    resizeAmount = 10;
    prefix = "C-Space";
    terminal = "xterm-256color";
  };

  programs.git = {
    enable = true;
    userName = "Richard Bishop";
    userEmail = "richard.bishop@crunchydata.com";
  };

  programs.mpv = {
    enable = true;
    config = {
      gpu-context = "wayland";
      vo="gpu";
      hwdec="vaapi";
    };
  };

  programs.fzf.enable = true;

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

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "dmenu-wl_run -i";
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

      output HDMI-A-1 mode 3840x2160@59.997Hz scale 2
      output DP-1 mode 3840x2160@59.997Hz scale 2
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

      set $lock_path '~/.config/sway/lock.sh'
      set $idle_path '~/.config/sway/idle.sh'

      exec $idle_path

      # Lock Button
      bindsym Mod4+Control+q exec $lock_path

      # Clear Mako notifications
      bindsym Mod4+c exec makoctl dismiss --all

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

  home.file.".config/sway/lock.sh" = {
    executable = true;
    text = ''
      #!/bin/sh

      exec swaylock --daemonize \
        --ignore-empty-password \
        --color 808080 \
        --scaling fit \
        --image ~/.config/sway/crunchy_logo.png
    '';
  };

  home.file.".config/sway/idle.sh" =  {
    executable = true;
    text = ''
      #!/bin/sh

      exec swayidle -w \
        timeout 300 '~/.config/sway/lock.sh; playerctl pause' \
        timeout 15 'if pgrep swaylock; then swaymsg "output * dpms off" && playerctl pause; fi' resume 'swaymsg "output * dpms on"' \
        before-sleep '~/.config/sway/lock.sh'
        before-sleep 'swaymsg "output * dpms off"'
        before-sleep 'playerctl pause' \
        after-resume 'swaymsg "output * dpms on"'
    '';
  };

  dconf.enable = true;

  home.packages = with pkgs; [
    # Sway tools
    dmenu-wayland
    swaylock
    swayidle
    wl-clipboard
    mako # notifications
    wob # volume/brightness bar
    wev # for getting key codes on Wayland
    playerctl # prev/play/next control of audio
    kanshi # monitor selection
    brightnessctl # Monitor brightness
    dconf

    # Linux hardware tools
    lshw
    dmidecode # BIOS
    libva-utils # GPU Hardware Acceleration
    vdpauinfo
    glxinfo
    vulkan-tools
    lm_sensors
    guvcview # webcam

    # Useful utilities
    slurp
    grim
    unzip
    parted
    jq
    wget
    pavucontrol
    pamixer
    ctags
    man-pages
    man-pages-posix

    # Fonts
    open-sans
    roboto-mono
    source-serif
    font-awesome
    liberation_ttf
    helvetica-neue-lt-std
    gnome.adwaita-icon-theme
    openmoji-color
    material-design-icons
    material-icons
    noto-fonts
    noto-fonts-emoji

    # Creature comforts
    alacritty
    firefox-wayland
    chromium-gpu
    gnome.geary # email
    gnome.nautilus # file explorer
    apostrophe # markdown editor
    zoom-us
    htop
    ffmpeg
    _1password-gui
    foliate # ePub reader
    gnome.simple-scan
    xwayland
    slack-hidpi
    spotify-hidpi
    ripgrep
    markets
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}
