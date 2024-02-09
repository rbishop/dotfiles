{ pkgs, settings, ... }:

let
  waybar = import ../shared/waybar.nix { settings = settings; };

  lockScreens = {
    crunchy = {
      executable = true;
      text = ''
        #!/bin/sh

        exec swaylock --daemonize \
          --ignore-empty-password \
          --color 808080 \
          --scaling fit \
          --image ${../wallpapers/crunchy.png}
      '';
    };

    forester = {
      executable = true;
      text = ''
        #!/bin/sh

        exec swaylock --daemonize \
          --ignore-empty-password \
          --scaling fill \
          --image ${../wallpapers/framework.png}
      '';
    };

    workstation = {
      executable = true;
      text = ''
        #!/bin/sh

        swaylock --daemonize \
          --ignore-empty-password \
          --image ~/Downloads/nix-wallpaper-mosaic-blue.png
      '';
    };
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

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = "sway"; 
    XDG_SESSION_TYPE = "wayland";
    XDG_RUNTIME_DIR = "/run/user/1000";
    XDG_SCREENSHOTS_DIR = "/home/${settings.username}/Screenshots";
    XDG_PICTURES_DIR = "/home/${settings.username}/Screenshots";
    EDITOR = "vim";
    GIT_EDITOR = "vim";
    BUNDLE_DITOR = "vim";
  };

  home.file.".config/sway/lock.sh" = lockScreens.${settings.hostName};
  home.file.".config/sway/power.sh" = {
    executable = true;
    source = ../scripts/power.sh;
  };
  home.file.".config/sway/idle.sh" = {
    executable = true;
    source = ../scripts/idle.sh;
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

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/datetime" = { automatic-timezone = true; };
      "org/gnome/system/location" = { enabled = true; };
    };
  };

  fonts.fontconfig.enable = true;

  services.blueman-applet.enable = true;

  services.kanshi = {
    enable = settings.laptop;
    extraConfig = ''
      profile {
        output "BOE 0x091D Unknown" enable mode 1920x1080@60.002Hz position 0,0 scale 1.25
      }

      profile {
        output "eDP-1" enable mode 2256x1504@59.999Hz position 0,0 scale 1.50
      }

      profile {
        output "eDP-1" disable
        output "Dell Inc. DELL U2720Q 3J9JV13" enable mode 3840x2160@60.000Hz position 0,0 scale 2.000000
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
    ignores = [
      "*.swp"
      "*.swo"
      "result/"
    ];
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
      ao = "alsa";
      audio-device = "auto";
    };
  };

  programs.fzf.enable = true;

  home.packages = with pkgs; [
    ltunify # Logitech Unifying Receiver
    amdgpu_top
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
