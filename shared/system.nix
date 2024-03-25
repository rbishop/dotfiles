{ config, pkgs, lib, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-derivations = true
      keep-outputs = true
      fallback = true
      warn-dirty = false
      auto-optimise-store = true
      max-jobs = auto

      connect-timeout = 5
      log-lines = 25
      min-free = 128000000
      max-free = 1000000000
    '';
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  time.timeZone = lib.mkForce null; # TZ set by desktop user

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.enableIPv6 = false; # Spectrum stopped working
  networking.useNetworkd = true;
  networking.nameservers = [ "192.168.88.42" "1.1.1.1" "1.0.0.1" ];
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 5201 6969 8008 8009 8010 9556 ];
    allowedTCPPortRanges = [ { from = 6881; to = 6889; } ];
    allowedUDPPorts = [ 9556 ];
    allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
  };

  # Use iwd for managing wireless networks
  networking.wireless.iwd = {
    enable = true;

    settings = {
      General = {
        EnableNetworkConfiguration = true;
        UseDefaultInterface = true;
        AddressRandomization = "network";
        RoamRetryInterval = 15;
      };

      Network = {
        EnableIPv6 = false;
      };
    };
  };

  networking.networkmanager = {
    enable = false;
    wifi.backend = "iwd";
  };

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  security.pam.services.swaylock = {
    #text = ''
    #  auth include login
    #'';
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
    libvdpau
    ddcutil
    ntfs3g
  ];

  environment.shells = [ pkgs.bash pkgs.fish ];

  programs.fish.enable = true;
  programs.sway.enable = true;
  programs.dconf.enable = true; # Required for Geary to work
  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      Host *.db.postgresbridge.com *-db.pgbridgedev.com
        User centos
        IdentityFile ~/.ssh/crunchy
        StrictHostKeyChecking accept-new
        UserKnownHostsFile /dev/null
    '';
  };

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Udev rules for the Logitech c920 webcam and DDC/CI devices, respectively
  services.udev.extraRules = ''
    SUBSYSTEM=="video4linux", KERNEL=="video[0-9]*", ATTR{index}=="0", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0892", RUN+="${pkgs.v4l-utils}/bin/v4l2-ctl -d $devnode --set-ctrl=focus_auto=0"
  '';
  #SUBSYSTEM=="i2c-dev", ACTION=="add", ATTR{name}=="AMDGPU DM*", TAG+="ddcci", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"

  services.openssh = {
    enable = true;
    authorizedKeysFiles = [ ".ssh/authorized_keys" ];
    settings = {
      PasswordAuthentication = false;
    };
  };

  # Required for Geary
  services.gnome = {
    gnome-keyring.enable = true;
    gnome-online-accounts.enable = true;
  };

  services.automatic-timezoned.enable = true;

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
    drivers = [ pkgs.cups-brother-hll2350dw ];
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
    mime.enable = true;
  };
}
