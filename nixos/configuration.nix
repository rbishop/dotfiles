# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
  networking.hostName = "";
  networking.useNetworkd = true;
  networking.interfaces.enp7s0.useDHCP = true;
  #networking.interfaces.wlp6s0.useDHCP = true;

  # Use iwd for managing wireless networks
  networking.wireless.iwd.enable = true;
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

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
  users.users.rb = {
    isNormalUser = true;
    extraGroups = [ "wheel" "sway" "networkmanager" "audio" "video" ];
    home = "/home/rb";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2u1Kf5Ff3OquFfQpIUPk0EEvkLIvy7+f9c9ilVD9P4 rb-mbp "];
    hashedPassword = "$6$jWajHUuXrf//Yr$K9dMJu.rqT/X3U6Lm8FLBIsZnidMyHukURSwJXmqyFu3V9Aq2PRlf3akLscIfFsAgSNTOw6gZNQyLrObg3Qi./";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    bluez-tools
    pulseaudio
  ];

  fonts.fonts = with pkgs; [
    roboto 
    roboto-mono
    font-awesome
  ];

  environment.shells = [ pkgs.zsh ];

  programs.sway.enable = true;
  programs.zsh.enable = true;
  programs.ssh.startAgent = true;
  programs.dconf.enable = true; # Required for Geary to work

  # List services that you want to enable:
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    authorizedKeysFiles = [ ".ssh/authorized_keys" ];
  };

  # Required for Geary
  services.gnome3 = {
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

  services.dbus = {
    enable = true;
    packages = with pkgs; [ gnome3.dconf ];
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
      ];
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
