# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

let
  settings = {
    username = "rbishop";
    email = "richard@rubiquity.com";
    hostName = "forester";
    waybar-order = [ "cpu" "temperature" "network#1" "network#2" "bluetooth" "pulseaudio" "idle_inhibitor" "battery" "clock" ];
    laptop = true;
    sensors = {
      cpu_temp = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
      battery = "BAT1";
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
    ];

  users.users.rbishop = {
    isNormalUser = true;
    extraGroups = [ "wheel" "sway" "networkmanager" "audio" "video" "i2c" ];
    home = "/home/rbishop";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2u1Kf5Ff3OquFfQpIUPk0EEvkLIvy7+f9c9ilVD9P4 rb-mbp "];
    hashedPassword = "$6$jWajHUuXrf//Yr$K9dMJu.rqT/X3U6Lm8FLBIsZnidMyHukURSwJXmqyFu3V9Aq2PRlf3akLscIfFsAgSNTOw6gZNQyLrObg3Qi./";
  };

  nix.settings.trusted-users = [ "root" "rbishop" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  home-manager.users.rbishop = homeConfig;

  services.hardware.bolt.enable = false;
  services.fprintd.enable = false;
  services.xserver.videoDrivers = [ "modesetting" ];
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };
  # Disabled until Framework AMD supports LVFS
  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };

  networking.hostName = settings.hostName;
  networking.interfaces.eth0.useDHCP = lib.mkDefault true;
  networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nix.settings.max-jobs = 16;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };

  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    bluez-tools
    pulseaudio
    v4l-utils
    ddcutil
    ntfs3g
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

  systemd.sleep.extraConfig = "HibernateDelaySec=2h";

  security.pam.services.swaylock = {
    fprintAuth = false;
    #text = ''
    #  auth include login
    #'';
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.sensor.iio.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ mesa libva ];
  };


  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "amdgpu" "iwlwifi" "k10temp" "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "net.ifnames=0"
    "mem_sleep_default=deep"
    "acpi_osi=\"!Windows 2020\""
    "resume=UUID=cf6c08cd-952e-4e82-8f00-3f60944800e8"
    "resume_offset=533760"
  ];

  boot.resumeDevice = "/dev/disk/by-uuid/cf6c08cd-952e-4e82-8f00-3f60944800e8";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/cf6c08cd-952e-4e82-8f00-3f60944800e8";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "discard=async" ];
    };

  boot.initrd.luks.devices."nixos".device = "/dev/disk/by-uuid/8631237a-371d-4aba-b7b9-1f058ece349c";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/cf6c08cd-952e-4e82-8f00-3f60944800e8";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "discard=async" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/cf6c08cd-952e-4e82-8f00-3f60944800e8";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" "discard=async" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/cf6c08cd-952e-4e82-8f00-3f60944800e8";
      fsType = "btrfs";
      options = [ "subvol=swap" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/C39A-125F";
      fsType = "vfat";
    };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
