# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, modulesPath, ... }:

let
  settings = {
    username = "rb";
    email = "richard@rubiquity.com";
    hostName = "montrachet";
    waybar-order = [ "cpu" "temperature" "network#1" "network#2" "bluetooth" "pulseaudio" "idle_inhibitor" "clock" ];
    laptop = false;
    sensors = {
      cpu_temp = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
      battery = null;
    };
  };

  homeConfig = import ../nixos/home.nix { inherit pkgs settings;  };

  steam-hidpi = pkgs.symlinkJoin {
    name = "steam";
    paths = [ pkgs.steam ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/steam --set GDK_SCALE "1.0"
    '';
  };
in
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      <home-manager/nixos>
      ../shared/system.nix
    ];

  users.users.rb = {
    isNormalUser = true;
    extraGroups = [ "wheel" "sway" "audio" "video" ];
    home = "/home/rb";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2u1Kf5Ff3OquFfQpIUPk0EEvkLIvy7+f9c9ilVD9P4 rb-mbp "];
    hashedPassword = "$6$jWajHUuXrf//Yr$K9dMJu.rqT/X3U6Lm8FLBIsZnidMyHukURSwJXmqyFu3V9Aq2PRlf3akLscIfFsAgSNTOw6gZNQyLrObg3Qi./";
  };

  environment.sessionVariables = {
    AMD_VULKAN_ICD = "RADV";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
  };

  environment.systemPackages = [ steam-hidpi ];

  home-manager.users.rb = homeConfig;

  networking.hostName = settings.hostName;

  nix.settings.max-jobs = 24;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ mesa.drivers libva vaapiVdpau ];
  };

  hardware.cpu.amd.updateMicrocode = true;

  services.xserver.videoDrivers = [ "modesetting" ];

  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };

  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';

  services.fstrim.enable = true;

  # Needed for nixos-generators to cross compile
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "net.ifnames=0" ];
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "dm-snapshot" "amdgpu" "kvm-amd" "k10temp" "nct6775" "uvcvideo" "btusb" "i2c-dev" ];
  boot.extraModulePackages = [];

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 1048576;
  };

  boot.initrd.luks.devices = {
    main = {
      device = "/dev/disk/by-partuuid/0d2db233-2104-49a6-a9ef-0f5748fe9989";
      preLVM = true;
      allowDiscards = true;
    };

    media = {
      device = "/dev/disk/by-uuid/02cd560e-e103-4ac7-b31e-c9da8e05685e";
      allowDiscards = true;
      preLVM = true;
    };

    backup = {
      device = "/dev/disk/by-uuid/9c2adebf-9f6d-48bd-a06b-ff03887a6d4c";
      allowDiscards = true;
      preLVM = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7944672b-dbfd-48e9-a470-20d7d4ea6ccc";
    fsType = "ext4";
    options = [ "rw" "data=ordered" "discard" "noatime" "nodiratime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4EFB-A6E8";
    fsType = "vfat";
  };

  fileSystems."/home/rb/Media" = {
    device = "/dev/disk/by-label/media";
    fsType = "ext4";
    options = ["rw" "data=ordered" "noatime" "nodiratime"];
  };

  fileSystems."/home/rb/Backup" = {
    device = "/dev/disk/by-label/backup";
    fsType = "ext4";
    options = ["rw" "data=ordered" "noatime" "nodiratime"];
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/c41af588-2f60-46d9-8b53-8ab5b05ab767"; }];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
