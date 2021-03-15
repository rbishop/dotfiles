{ config, pkgs, ... }:

let
  # Spotify to pass a command-line flag to force better scaling.
  spotify-4k = pkgs.symlinkJoin {
    name = "spotify";
    paths = [ pkgs.spotify ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/spotify \
        --add-flags "--force-device-scale-factor=1.75"
    '';
  };

in

{ # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "rb";
  home.homeDirectory = "/home/rb";

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = "sway"; 
    XDG_SESSION_TYPE = "wayland";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window.startup_mode = "Maximized";
      scrolling.history = 10000;

      font = {
        size = 14.0;
        use_thin_strokes = true;
      };

      command = {
        program = "alacritty";
        args = [ "-e" "zsh" ];
      };
    };
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    prezto.enable = true;

    loginExtra = ''
      if [ "$(tty)" == "/dev/tty1" ]; then
        exec sway
      fi
    '';
  };

  programs.vim = { 
    enable = true;

    settings = {
      expandtab = true;
      number = true;
      shiftwidth = 4;
      tabstop = 4;
    };

    extraConfig = ''
      syntax on
      set autowriteall
      set splitright
      :au FocusLost * :wa

      set cursorline
      hi CursorLine cterm=NONE ctermbg=235
      set cursorcolumn
      hi CursorColumn cterm=NONE ctermbg=235
    '';
  };
  
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 5000;
    keyMode = "vi";
    resizeAmount = 10;
    shortcut = "a";
    terminal = "xterm-256color";
  };

  programs.git = {
    enable = true;
    userName = "Richard Bishop";
    userEmail = "richard@rubiquity.com";
  };

  programs.waybar = {
    enable = true;
    #systemd.enable = true;

    settings = [{
      layer = "bottom";
      position = "top";
      height = 30;

      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "network" "cpu" "memory" "temperature" "backlight" "clock" "tray" ];
      modules = {
        "cpu" = {
          format = "{usage}% ";
          tooltip = false;
        };

        "memory" = {
          format = "{}% ";
        };

        "temperature" = {
          hwmon-path = "/sys/class/hwmon/hwmon4/temp2_input";
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = ["" "" ""];
        };

        "backlight" = {
          format = "{percent}% {icon}";
          format-icons =  ["" ""];
        };

        "clock" = {};

        "tray" = {
          spacing = 10;
        };
      };
    }];
  };

  wayland.windowManager.sway = {
    enable = true;
    xwayland = false;
    wrapperFeatures.gtk = true;
    config = {
      terminal = "alacritty";
      modifier = "Mod4";
      bars = [
        { command = "${pkgs.waybar}/bin/waybar"; }
      ];
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

      output HDMI-A-1 mode 3840x2160@60Hz scale 2
      output DP-1 mode 3840x2160@60Hz scale 2

      # Copy and paste functionality
      bindsym Control_L+Shift_L+c exec wl-copy
      bindsym Control+Shift+v exec wl-paste

      # Monitor brightness
      bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
      bindsym XF86MonBrightnessUp exec brightnessctl set +5%

      # Audio playback controls
      bindsym XF86AudioPrev exec playerctl previous
      bindsym XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next

      # Volume toggles
      #bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
      #bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
      #bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
      bindsym XF86AudioMute exec amixer set Master toggle
      bindsym XF86AudioLowerVolume exec amixer set Master 10%-
      bindsym XF86AudioRaiseVolume exec amixer set Master 10%+
    '';
  };

  home.packages = with pkgs; [
    # Sway tools
    swaylock
    swayidle
    wl-clipboard
    mako
    alacritty
    dmenu
    wob
    wev # for getting key codes
    playerctl # prev/play/next control of audio
    brightnessctl

    firefox
    chromium

    # Linux hardware tools
    lshw
    dmidecode # BIOS
    libva-utils # GPU Hardware Acceleration
    glxinfo

    gnome3.geary # email
    vulkan-tools
    lm_sensors

    # Useful utilities
    unzip
    parted
    pavucontrol
    transmission # torrents

    # Creature comforts
    spotify-4k
    typora
    zoom-us
    htop
    fzf
    ffmpeg
  ];

  programs.firefox = {
    enable = true;
    #package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    #  forceWayland = true;
    #};
  };

  programs.mpv = {
    enable = true;
    config = {
      gpu-context = "wayland";
      vo="gpu";
      hwdec="vaapi";
    };
  };

  # TODO: Setup dbus sockets that mpris needs
  #systemd.user.services.mpris-proxy = {
  #  Unit.Description = "mpris-proxy";
  #  Unit.After = [ "network.target" "sound.target" ];
  #  Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  #  Install.WantedBy = [ "default.target" ];
  #};

  #services.blueman-applet.enable = true;

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
