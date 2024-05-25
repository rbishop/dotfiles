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

    montrachet = {
      executable = true;
      text = ''
        #!/bin/sh

        swaylock --daemonize \
          --ignore-empty-password \
          --image ${../wallpapers/workstation.png}
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
    NIXOS_OZONE_WL = "1";
    NIXOS_OZONE_PLATFORM = "wayland";
    GDK_DPI_SCALE = 1.0;
    GDK_SCALE = "2.0";
    QT_SCALE_FACTOR = "2";
    QT_QPA_PLATFORM ="xcb";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_WAYLAND_FORCE_DPI = "physical";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    EDITOR = "nvim";
    GIT_EDITOR = "nvim";
    BUNDLE_DITOR = "nvim";
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
  home.file.".config/shikane/config.toml" = {
    text = ''
      [[profile]]
      name = "latitude"
      exec = [ "echo 'switched to latitude'" ]
      [[profile.output]]
      match = "/BOE 0x091D/"
      enable = true
      mode = { width = 1920, height = 1080, refresh = 60.002 }
      position = { x = 0, y = 0 }
      scale = 1.25

      [[profile]]
      name = "framework"
      exec = [ "echo 'switched to framework'" ]
      [[profile.output]]
      match = "/BOE 0x0BCA/"
      enable = true
      mode = { width = 2256, height = 1504, refresh = 59.999 }
      position = { x = 0, y = 0 }
      scale = 1.5

      [[profile]]
      name = "homeoffice"
      exec = [ "echo 'switched to homeoffice'" ]
      [[profile.output]]
      match = "/U2720Q/"
      enable = true
      mode = { width = 3840, height = 2160, refresh = 60 }
      position = { x = 0, y = 0 }
      scale = 2.0

      [[profile.output]]
      match = "/eDP-1/"
      enable = false
    '';
  };

  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 24;
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

  systemd.user.services.shikane = {
    Unit = {
      Description = "shikane output switcher";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.shikane}/bin/shikane";
      Restart = "always";
    };
  };

  gtk = {
    enable = true;
    font.name = "Open Sans 12";
    font.size = 12;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita";
    };

    gtk3.extraConfig = {
      gtk-recent-files-enabled = false;
      gtk-recent-files-limit = 0;
      gtk-recent-files-max-age = 0;
    };

    gtk4.extraConfig = {
      gtk-recent-files-enabled = false;
      gtk-recent-files-max-age = 0;
      gtk-recent-files-limit = 0;
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.fish = {
    enable = true;
    plugins = [
      { name = "grc"; src = pkgs.fishPlugins.grc; }
      { name = "done"; src = pkgs.fishPlugins.done; }
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish; }
      { name = "hydro"; src = pkgs.fishPlugins.hydro; }
      { name = "forgit"; src = pkgs.fishPlugins.forgit; }
    ];

    loginShellInit = ''
      if test (tty) = "/dev/tty1"
        WLR_RENDERER=1 sway
      end
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = false;
    vimAlias = true;
    withRuby = true;
    withPython3 = true;
    extraLuaConfig = pkgs.lib.fileContents ../packages/neovim/init.lua;
    plugins = with pkgs.vimPlugins; [
      vim-plug nvim-lspconfig Rename vim-endwise vim-surround
      neovim-sensible nvim-fzf nvim-fzf-commands supertab
      swift-vim zig-vim vim-crystal hare-vim neovim-ayu vim-wayland-clipboard
      open-browser-vim open-browser-github-vim nerdtree supertab
      plenary-nvim fzf-lsp-nvim lsp-zero-nvim none-ls-nvim nvim-cmp cmp-nvim-lsp
    ];
  };

  home.file.".config/nvim/lua/ruby.lua" = {
    source = ../packages/neovim/langs/ruby.lua;
  };

  programs.vim.enable = true; 
  
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
      ".irbrc"
      ".DS_Store"
    ];

    aliases = {
      recent = "! git branch --sort=-committerdate --format=\"%(committerdate:relative)%09%(refname:short)\" | head -10";
      smartlog = "log --graph --pretty=format:'commit: %C(bold red)%h%Creset %C(red)[%H]%Creset %C(bold magenta)%d %Creset%ndate: %C(bold yellow)%cd %Creset%C(yellow)%cr%Creset%nauthor: %C(bold blue)%an%Creset %C(blue)[%ae]%Creset%n%C(cyan)%s%n%Creset'";
    };

    extraConfig = {
      init = {
        defaultBranch = "main";
      };

      core = {
        pager = "delta";
      };

      color = {
        diff = "auto";
        branch = "auto";
        status = "auto";
      };

      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };

      branch = {
        sort = "-committerdate";
      };

      filter = {
        clean = "git-stripspace";
      };

      commit = {
        verbose = true;
      };

      merge = {
        conflictStyle = "zdiff3";
      };

      rebase = {
        autosquash = true;
      };

      push = {
        default = "current";
        autoSetupRemote = true;
      };

      fetch = {
        prune = true;
        pruneTags = true;
      };

      pull = {
        ff = "only";
        rebase = true;
      };

    };
  };

  programs.mpv = {
    enable = true;
    config = {
      vo = "dmabuf-wayland";
      gpu-api = "vulkan";
      hwdec = "auto";
      gpu-context = "waylandvk";
      hdr-compute-peak = "no";
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
