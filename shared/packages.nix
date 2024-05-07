{ pkgs, ... }:

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
  iwgtk
  htop
  jq
  man-pages
  man-pages-posix
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
  rubyPackages.solargraph
  lnav

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
  vlc
  xwayland
  zathura
  zoom-us
  transmission-gtk
]
