# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <home-manager/nixos>
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_5_15;
  nixpkgs.config.allowUnfree = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.hostName = "crunchy";
  networking.useNetworkd = true;
  networking.enableIPv6 = true;

#  fonts.fonts = with pkgs; [
#    open-sans
#    roboto-mono
#    source-serif
#    font-awesome
#    gnome.adwaita-icon-theme
#  ];

  # Use iwd for managing wireless networks
  # networking.wireless.iwd.enable = true;
  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 22 9556 51416 ];
  networking.firewall.allowedUDPPorts = [ 9556 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
  networking.firewall.enable = true;

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      HandlePowerKey=suspend
    '';
  };

  documentation.enable = true;
  documentation.man.enable = true;
  documentation.dev.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable sound.
  sound.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rbishop = {
    isNormalUser = true;
    extraGroups = [ "wheel" "sway" "networkmanager" "audio" "video" "i2c" ];
    home = "/home/rbishop";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2u1Kf5Ff3OquFfQpIUPk0EEvkLIvy7+f9c9ilVD9P4 rb-mbp "];
    hashedPassword = "$6$jWajHUuXrf//Yr$K9dMJu.rqT/X3U6Lm8FLBIsZnidMyHukURSwJXmqyFu3V9Aq2PRlf3akLscIfFsAgSNTOw6gZNQyLrObg3Qi./";
  };
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.rbishop = import ./home.nix;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    bluez-tools
    pulseaudio
    libvdpau
    v4l-utils
    ddcutil
    ntfs3g
  ];

  environment.shells = [ pkgs.zsh ];

  programs.ssh.startAgent = true;

  # List services that you want to enable:
  services.resolved = {
    enable = true;
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    dnssec = "allow-downgrade";
  };

  # Udev rules for the Logitech c920 webcam and DDC/CI devices, respectively
  services.udev.extraRules = ''
    SUBSYSTEM=="video4linux", KERNEL=="video[0-9]*", ATTR{index}=="0", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0892", RUN+="${pkgs.v4l-utils}/bin/v4l2-ctl -d $devnode --set-ctrl=focus_auto=0"
  '';
  #SUBSYSTEM=="i2c-dev", ACTION=="add", ATTR{name}=="AMDGPU DM*", TAG+="ddcci", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    authorizedKeysFiles = [ ".ssh/authorized_keys" ];
  };

  # Required for Geary
  services.gnome = {
    gnome-keyring.enable = true;
    gnome-online-accounts.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse = {
      enable = true;
    };
  };

  services.blueman.enable = true;

  services.upower.enable = true;

  services.dbus = {
    enable = true;
    packages = with pkgs; [ dconf ];
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.canon-cups-ufr2 ];
  };

  # Mostly used for printer discovery
  services.avahi.enable = true;

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
