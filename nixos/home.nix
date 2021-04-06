{ config, pkgs, ... }:

let
  # Wrap Spotify to force better scaling on HiDPI
  spotify-4k = pkgs.symlinkJoin {
    name = "spotify";
    paths = [ pkgs.spotify ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/spotify \
        --add-flags "--force-device-scale-factor=2"
    '';
  };

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
    VDPAU_DRIVER = "radeonsi";
  };

  home.file.".icons/default" = {
    source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ-AA";
  };

  xsession.pointerCursor = {
    name = "Vanilla-DMZ-AA";
    package = pkgs.vanilla-dmz;
    size = 48;
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

    initExtraFirst = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
      fi
    '';
  };

  programs.vim = { 
    enable = true;

    plugins = with pkgs.vimPlugins; [
      supertab nerdtree vim-endwise vinegar sensible Rename
      command-t vim-go zig-vim vim-plug
    ];

    settings = {
      expandtab = true;
      number = true;
      shiftwidth = 4;
      tabstop = 4;
    };

    extraConfig = ''
      syntax on
      filetype plugin indent on
      set autowriteall
      set splitright
      :au FocusLost * :wa

      set cursorline
      hi CursorLine cterm=NONE ctermbg=235
      set cursorcolumn
      hi CursorColumn cterm=NONE ctermbg=235
      nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

      autocmd InsertLeave * if expand('%') != ''\'''\' | update | endif
      autocmd StdinReadPre * let s:std_in=1

      if $COLORTERM == 'gnome-terminal'
          set t_Co=256
      endif

      let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
      if empty(glob(data_dir . '/autoload/plug.vim'))
        silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
      endif
      call plug#begin("~/.vim/plugged")

      Plug 'bakpakin/janet.vim'
      call plug#end()
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
          on-click-right = "blueman-manager";
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
      bars = []; # systemd manages waybar
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

      exec mkfifo $SWAYSOCK.wob && tail -f $SWAYSOCK.wob | wob

      # Monitor brightness
      bindsym XF86MonBrightnessDown exec brightnessctl set 5%- | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > $SWAYSOCK.wob
      bindsym XF86MonBrightnessUp exec brightnessctl set +5% | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > $SWAYSOCK.wob

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

      # Lock Button
      bindsym Mod4+Control+q exec $lock_path

      exec $idle_path
    '';
  };

  services.blueman-applet.enable = true;

  home.file.".config/sway/lock.sh" = {
    executable = true;
    text = ''
      #!/bin/sh

      swaylock --daemonize \
        --ignore-empty-password \
        --image ~/Downloads/nix-wallpaper-mosaic-blue.png
    '';
  };

  home.file.".config/sway/idle.sh" =  {
    executable = true;
    text = ''
      #!/bin/sh

      exec swayidle -w \
        timeout 300 ~/.config/sway/lock.sh \
        timeout 310 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
        timeout 15 'if pgrep swaylock; then swaymsg "output * dpms off" && playerctl pause; fi' \
        resume 'if pgrep swaylock; then swaymsg "output * dpms on"; fi' \
        before-sleep ~/.config/sway/lock.sh; playerctl pause
    '';
  };

  home.packages = with pkgs; [
    # Sway tools
    dmenu-wayland
    swaylock
    swayidle
    wl-clipboard
    mako
    wob
    wev # for getting key codes on Wayland
    playerctl # prev/play/next control of audio
    brightnessctl # Monitor brightness
    gtk3

    # Linux hardware tools
    lshw
    dmidecode # BIOS
    libva-utils # GPU Hardware Acceleration
    vdpauinfo
    glxinfo
    vulkan-tools
    lm_sensors

    # Useful utilities
    unzip
    parted
    jq
    wget
    pavucontrol
    transmission-gtk # torrents
    pamixer

    # Creature comforts
    alacritty
    firefox-wayland
    chromium-gpu
    gnome3.geary # email
    spotify-4k
    ghostwriter
    zoom-us
    htop
    ffmpeg
    radeontop
    ltunify # Logitech Unifying Receiver
    _1password-gui
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