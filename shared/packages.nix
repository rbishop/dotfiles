{ pkgs, ... }:

let
  typora-wayland = pkgs.symlinkJoin {
    name = "typora";
    paths = [ pkgs.typora ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/typora \
        --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
    '';
  };

  ruby-lsp = pkgs.callPackage ./ruby-lsp.nix {};
  inko = pkgs.callPackage ../packages/inko/default.nix {};
in
with pkgs; [
  # Sway tools
  brightnessctl # Monitor brightness
  dconf
  dmenu-wayland
  mako # notifications
  playerctl # prev/play/next control of audio
  shikane # display output switching
  sway-contrib.grimshot
  swayidle
  swaylock
  wev # for getting key codes on Wayland
  wl-clipboard
  wob # volume/brightness bar
  wofi

  # Linux hardware tools
  lshw
  dmidecode # BIOS
  libva-utils # GPU Hardware Acceleration
  vulkan-tools
  lm_sensors
  guvcview # webcam
  glxinfo

  # Useful utilities
  alloy6
  tlaplus
  ctags
  cachix
  dig
  file
  fio
  gnumake
  gparted
  grim
  htop
  jq
  man-pages
  man-pages-posix
  networkmanager
  networkmanagerapplet
  pamixer
  parted
  pavucontrol
  rar
  ripgrep
  slurp
  sysstat
  unzip
  wget

  # Fonts
  font-awesome
  gnome.adwaita-icon-theme
  helvetica-neue-lt-std
  liberation_ttf
  material-design-icons
  material-icons
  noto-fonts
  noto-fonts-emoji
  open-sans
  openmoji-color
  roboto-mono
  source-serif

  # Dev Tools
  git-absorb
  delta
  ruby-lsp
  crystalline
  lnav
  tmuxp
  watchman
  inko
  zig
  zls

  # Creature comforts
  _1password-gui
  alacritty
  apostrophe # markdown editor
  chromium
  cinnamon.nemo # file explorer
  ffmpeg
  firefox-wayland
  foliate # ePub reader
  gnome.geary # email
  gnome.simple-scan
  grc # colorizer
  thunderbirdPackages.thunderbird-115
  libreoffice
  masterpdfeditor4
  planify
  signal-desktop
  slack
  spotify
  tailscale
  trayscale
  typora-wayland
  vlc
  xwayland
  zathura
  zoom-us
  transmission_4-gtk
]
