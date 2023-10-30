{ pkgs, settings, ... }:

let
  waybar = import ../shared/waybar.nix { settings = settings; };

  laptopLockScreen = {
    executable = true;
    text = ''
      #!/bin/sh

      exec swaylock --daemonize \
        --ignore-empty-password \
        --color 808080 \
        --scaling fill \
        --image ~/Downloads/nixos-wallpaper.png
    '';
  };
  workstationLockScreen = {
    executable = true;
    text = ''
      #!/bin/sh

      swaylock --daemonize \
        --ignore-empty-password \
        --image ~/Downloads/nix-wallpaper-mosaic-blue.png
    '';
  };
in
{
  imports = [
    ../shared/alacritty.nix
    ../shared/sway.nix
    waybar
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.username = settings.username;
  home.homeDirectory = "/home/${settings.username}";
  home.file.".config/sway/lock.sh" = if settings.laptop then laptopLockScreen else workstationLockScreen;

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = "sway"; 
    XDG_SESSION_TYPE = "wayland";
    XDG_RUNTIME_DIR = "/run/user/1000";
    EDITOR = "vim";
    GIT_EDITOR = "vim";
    BUNDLE_DITOR = "vim";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  home.file.".icons/default" = {
    source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  };

  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 32;
    gtk.enable = true;
  };

  dconf.enable = true;

  fonts.fontconfig.enable = true;

  services.blueman-applet.enable = true;

  services.kanshi = {
    enable = settings.laptop;
    extraConfig = ''
      profile {
        output "eDP-1" enable mode 2256x1504@59.999Hz position 0,0 scale 1.50
      }

      profile {
        output "eDP-1" disable
        output "DP-3" enable mode 3840x2160@60.000Hz position 0,0 scale 2.000000
      }
    '';
  };

  gtk = {
    enable = true;
    font.name = "Open Sans 12";
    font.size = 12;
    theme.name = "Adwaita";

    gtk3.extraConfig = {
      gtk-recent-files-enabled = false;
      gtk-recent-files-limit = 0;
      gtk-recent-files-max-age = 0;
      gtk-cursor-theme-name = "Vanilla-DMZ";
      gtk-cursor-theme-size = 32;
    };

    gtk4.extraConfig = {
      gtk-recent-files-enabled = false;
      gtk-recent-files-max-age = 0;
      gtk-cursor-theme-name = "Vanilla-DMZ";
      gtk-cursor-theme-size = 32;
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.zsh = {
    enable = true;
    autocd = true;
    loginExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
      fi
    '';

    prezto = {
      enable = true;
      prompt.theme = "sorin";
      editor.keymap = "emacs";
      pmodules = [
        "environment"
        "terminal"
        "editor"
        "history"
        "directory"
        "spectrum"
        "utility"
        "git"
        "completion"
        "prompt"
      ];
    };
  };

  programs.vim = { 
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-plug ];
    extraConfig = ''
      ${builtins.readFile ../.vimrc}
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
    extraConfig = ''
      # browser style tab navigation
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t:$

      # left and right window navigation
      bind -n M-Left select-window -t:-1
      bind -n M-Right select-window -t:+1

      # vim style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # split windows into panes like vim
      bind s split-window -v
      bind v split-pane -h

      bind -r H resize-pane -L
      bind -r J resize-pane -D
      bind -r K resize-pane -U
      bind -r L resize-pane -R

      set -g status-style "bg=olive,fg=black"
      set -g window-status-current-style "bg=olive,fg=black,reverse,bold"

      set -g status-left ""
      set -g status-right ""
    '';
  };

  programs.git = {
    enable = true;
    userName = "Richard Bishop";
    userEmail = settings.email;
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      gpu-context = "wayland";
      vo = "gpu";
      hwdec = "vaapi";
      glsl-shader = "~~/shaders/FSRCNNX_x2_16-0-4-1.glsl";
      ao = "alsa";
      audio-device = "auto";
    };

    bindings = {
      "CTRL+0" = "no-osd change-list glsl-shaders clr \"\"; show-text \"Shaders cleared\"";
      "CTRL+1" = "no-osd change-list glsl-shaders set \"~~/shaders/FSRCNNX_x2_16-0-4-1.glsl\"; show-text \"FSRCNNX 16\"";
      "CTRL+2" = "no-osd change-list glsl-shaders set \"~~/shaders/FSRCNNX_x2_8-0-4-1.glsl\"; show-text \"FSRCNNX 8\"";
      "CTRL+3" = "no-osd change-list glsl-shaders set \"~~/shaders/FSR.glsl\"; show-text \"FSR\"";
    };
  };

  programs.fzf.enable = true;

  home.file.".config/sway/idle.sh" =  {
    executable = true;
    text = ''
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
        after-resume 'swaymsg "output * dpms on"'
    '';
  };

  home.packages = with pkgs; [
    ltunify # Logitech Unifying Receiver
    amdgpu_top
    transmission-gtk
  ] ++ (import ../shared/packages.nix pkgs);

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
