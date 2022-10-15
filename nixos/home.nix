{ pkgs, settings, ... }:

let
  waybar = import ../shared/waybar.nix { settings = settings; };
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
    EDITOR = "vim";
    GIT_EDITOR = "vim";
    BUNDLE_DITOR = "vim";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  home.file.".icons/default" = {
    source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ-AA";
  };

  home.pointerCursor = {
    name = "Vanilla-DMZ-AA";
    package = pkgs.vanilla-dmz;
    size = 48;
  };

  dconf.enable = true;

  fonts.fontconfig.enable = true;

  services.blueman-applet.enable = true;

  gtk = {
    enable = true;
    font.name = "Open Sans 12";
    font.size = 12;
    theme.name = "Adwaita";

    gtk3.extraConfig = {
      gtk-recent-files-enabled = "FALSE";
      gtk-recent-files-limit = 0;
      gtk-recent-files-max-age = 0;
    };

    gtk4.extraConfig = {
      gtk-recent-files-enabled = "FALSE";
      gtk-recent-files-max-age = 0;
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
  };

  programs.git = {
    enable = true;
    userName = "Richard Bishop";
    userEmail = settings.email;
  };

  programs.mpv = {
    enable = true;
    config = {
      gpu-context = "wayland";
      vo = "gpu";
      hwdec = "vaapi";
    };
  };

  programs.fzf.enable = true;

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
    radeontop
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
