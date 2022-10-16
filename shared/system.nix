{ config, pkgs, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.firmwareLinuxNonfree pkgs.wireless-regdb ];
  hardware.enableRedistributableFirmware = true;
  hardware.i2c.enable = true;

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    powerOnBoot = true;
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.enableIPv6 = true;
  networking.useNetworkd = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 5201 6969 8008 8009 8010 9556 ];
  networking.firewall.allowedTCPPortRanges = [ { from = 6881; to = 6889; } ];
  networking.firewall.allowedUDPPorts = [ 9556 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];

  # Use iwd for managing wireless networks
  # networking.wireless.iwd.enable = true;
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
    "" # clear old command
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  ];

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # just for the laptop
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

  sound.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    bluez-tools
    pulseaudio
    v4l-utils
    ddcutil
    ntfs3g
  ];

  environment.shells = [ pkgs.zsh ];

  programs.sway.enable = true;
  programs.zsh.enable = true;
  programs.ssh.startAgent = true;
  programs.dconf.enable = true; # Required for Geary to work

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
}
