# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

let
  settings = {
    username = "rbishop";
    email = "richard.bishop@crunchydata.com";
    hostName = "crunchy";
    waybar-order = [ "cpu" "temperature" "network#1" "network#2" "bluetooth" "pulseaudio" "idle_inhibitor" "battery" "clock" ];
    laptop = true;
    sensors = {
      cpu_temp = "/sys/devices/platform/coretemp.0/hwmon/";
      battery = "BAT0";
    };
  };

  homeConfig = import ../nixos/home.nix { inherit pkgs settings;  };
in
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      <home-manager/nixos>
      ../shared/system.nix
      ../modules/usb-wakeup-disable.nix
    ];

  users.users.rbishop = {
    isNormalUser = true;
    extraGroups = [ "wheel" "sway" "audio" "video" "i2c" ];
    home = "/home/rbishop";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2u1Kf5Ff3OquFfQpIUPk0EEvkLIvy7+f9c9ilVD9P4 rb-mbp "];
    hashedPassword = "$6$jWajHUuXrf//Yr$K9dMJu.rqT/X3U6Lm8FLBIsZnidMyHukURSwJXmqyFu3V9Aq2PRlf3akLscIfFsAgSNTOw6gZNQyLrObg3Qi./";
  };

  nix.settings.trusted-users = [ "root" "rbishop" ];
  home-manager.users.rbishop = homeConfig;

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=60m
    SuspendState=mem
  '';

  hardware.usb.wakeupDisabled = [
    {
      vendor = "8087";
      product = "0026";
      wakeup = true;
    }
  ];

  services.hardware.bolt.enable = true;
  services.fstrim.enable = true;

  networking.hostName = settings.hostName;
  networking.interfaces.eth0.useDHCP = lib.mkDefault true;
  networking.interfaces.wlan0.useDHCP = lib.mkDefault true;
  networking.extraHosts = ''
    127.0.0.1 twitter.com
    127.0.0.1 news.ycombinator.com
    127.0.0.1 lobste.rs
    127.0.0.1 www.patsfans.com
    127.0.0.1 www.espn.com
    127.0.0.1 www.totalwine.com
    127.0.0.1 bevmo.com
    127.0.0.1 www.linkedin.com
    127.0.0.1 forum.celticsstrong.com
  '';

  nix.settings.max-jobs = 16;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
         governor = "powersave";
         turbo = "never";
      };
      charger = {
         governor = "performance";
         turbo = "auto";
      };
    };
  };

  environment.systemPackages = with pkgs; [ osquery ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    openFirewall = true;
  };

  systemd.services.osqueryd = {
    after = [ "network.target" "syslog.service" ];
    description = "The osquery daemon";
    serviceConfig = {
      ExecStart = "${pkgs.osquery}/bin/osqueryd --flagfile ${config.users.users.rbishop.home}/.config/osqueryd/osqueryd.flags";
      PIDFile = "/run/osquery/osqueryd.pid";
      LogsDirectory = "/var/log/osquery";
      StateDirectory = "/var/lib/osquery/osquery.db";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.tmpfiles.rules = [
    "d /run/osquery/osqueryd.pid 0755 root root -"
  ];

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
    '';
  };

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libva
    ];
  };

  boot.kernelPackages = pkgs.linuxPackages_6_7;
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "ddcci_backlight" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" "i2c-dev" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];
  boot.kernelParams = [ "button.lid_init_state=open" "net.ifnames=0" "pcie_ports=native" "mem_sleep_default=deep" "resume=/dev/mapper/swap" ];
  boot.extraModprobeConfig = ''
    options ddcci dyndbg delay=100
    options ddcci_backlight dyndbg
  '';

  boot.initrd.luks.devices.crypted = {
    device = "/dev/disk/by-uuid/b3acb1e2-ed60-4980-b750-82152ed292ea";
    preLVM = true;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/55e9c0d3-eb7c-43d2-b267-6b130c1daa37";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D25C-A9CF";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/d9f97245-1721-4db2-ba5d-ec1df92c853e"; }
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
