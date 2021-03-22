{ config, pkgs, ... }:

let
  # Spotify to pass a command-line flag to force better scaling.
  spotify-4k = pkgs.symlinkJoin {
    name = "spotify";
    paths = [ pkgs.spotify ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/spotify \
        --add-flags "--force-device-scale-factor=2"
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
  home.file.".icons/default" = {
    source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = "sway"; 
    XDG_SESSION_TYPE = "wayland";
    XCURSOR_THEME = "Vanilla-DMZ";
    XCURSOR_SIZE = 64;
  };

  xsession.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 64;
  };

  gtk.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      window.startup_mode = "Maximized";
      scrolling.history = 10000;
      live_config_reload = true;

      font = {
        size = 14.0;
        use_thin_strokes = true;
      };

      command = {
        program = "alacritty";
        args = [ "-e" "zsh" ];
      };

      key_bindings = [
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
      ];
    };
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    prezto.enable = true;

    initExtraFirst = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
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
    systemd.enable = true;

    settings = [{
      layer = "bottom";
      position = "top";
      height = 30;

      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "network" "pulseaudio" "cpu" "temperature" "backlight" "clock"  ];
      modules = {
        "network" = {
          interval = 5;
          interface = "enp7s0";
          format-ethernet = "  {ipaddr}/{cidr}";
          format-wifi = "  {essid}   {signalStrength}";
          tooltip = true;
          tooltip-format = ''
            {ifname}
            {ipaddr}/{cidr}
             {bandwidthDownBits}
             {bandwidthUpBits}'';
        };

        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-bluetooth = "sup";
          format-muted = "Muted ";
          format-icons = {
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
          scroll-step = 5.0;
          tooltip = true;
        };

        "cpu" = {
          format = "{usage}% ";
          tooltip = true;
        };

        "temperature" = {
          interval = 5;
          hwmon-path = "/sys/class/hwmon/hwmon4/temp2_input";
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        "backlight" = {
          format = "{percent}% {icon}";
          format-icons =  [ "" "" "" "" ];
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
    xwayland = false;
    wrapperFeatures.gtk = true;
    systemdIntegration = true;#
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "dmenu-wl_run -i";
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

      # Copy and Paste
      #bindsym Control+C exec wl-copy
      #bindsym Control+V exec wl-paste
      
      # Monitor brightness
      bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
      bindsym XF86MonBrightnessUp exec brightnessctl set +5%

      # Audio playback controls
      bindsym XF86AudioPrev exec playerctl previous
      bindsym XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next

      # Volume toggles
      bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
      bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5% 
      bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%

      # Lock Button
      bindsym Mod4+Control+q exec swaylock

      set $locker 'swaylock --daemonize --ignore-empty-password --color 1d2021'
      exec swayidle -w \
        timeout 300 $locker \
        timeout 330 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
        timeout 30 'if pgrep swaylock; then swaymsg "output * dpms off"; fi' \
        resume 'if pgrep swaylock; then swaymsg "output * dpms on"; fi' \
        before-sleep $locker
    '';
  };

  services.blueman-applet.enable = true;

  home.packages = with pkgs; [
    # Sway tools
    swaylock
    swayidle
    wl-clipboard
    mako
    dmenu-wayland
    wob
    wev # for getting key codes on Wayland
    playerctl # prev/play/next control of audio
    brightnessctl # Monitor brightness
    gtk3

    # Linux hardware tools
    lshw
    dmidecode # BIOS
    libva-utils # GPU Hardware Acceleration
    glxinfo
    vulkan-tools
    lm_sensors

    # Useful utilities
    unzip
    parted
    jq
    pavucontrol
    transmission # torrents

    # Creature comforts
    alacritty
    firefox-wayland
    chromium
    gnome3.geary # email
    spotify-4k
    #typora
    zoom-us
    htop
    ffmpeg
    ltunify # Logitech Unifying Receiver
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
