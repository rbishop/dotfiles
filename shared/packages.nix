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

  slack-wayland = pkgs.symlinkJoin {
    name = "slack";
    paths = [ pkgs.slack ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/slack --add-flags "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer --ozone-platform=wayland"
    '';
  };

  spotify-wayland = pkgs.symlinkJoin {
    name = "spotify";
    paths = [ pkgs.spotify ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/spotify --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
    '';
  };
in
with pkgs; [
  # Sway tools
  dmenu-wayland
  wofi
  swaylock
  swayidle
  sway-contrib.grimshot
  wl-clipboard
  mako # notifications
  wob # volume/brightness bar
  wev # for getting key codes on Wayland
  playerctl # prev/play/next control of audio
  brightnessctl # Monitor brightness
  dconf

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

  # Creature comforts
  _1password-gui
  alacritty
  apostrophe # markdown editor
  authy
  chromium-gpu
  cinnamon.nemo # file explorer
  ffmpeg
  firefox-wayland
  foliate # ePub reader
  gnome.geary # email
  gnome.simple-scan
  thunderbirdPackages.thunderbird-115
  libreoffice
  masterpdfeditor4
  planify
  signal-desktop
  slack-wayland
  spotify-wayland
  tailscale
  vlc
  xwayland
  zathura
  zoom-us
]
