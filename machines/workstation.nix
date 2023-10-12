# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, modulesPath, ... }:

let
  settings = {
    username = "rb";
    email = "richard@rubiquity.com";
    waybar-order = [ "memory" "cpu" "temperature" "network#1" "network#2" "bluetooth" "pulseaudio" "idle_inhibitor" "clock" ];
    laptop = false;
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

  users.users.rb = {
    isNormalUser = true;
    extraGroups = [ "wheel" "sway" "networkmanager" "audio" "video" "i2c" ];
    home = "/home/rb";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2u1Kf5Ff3OquFfQpIUPk0EEvkLIvy7+f9c9ilVD9P4 rb-mbp "];
    hashedPassword = "$6$jWajHUuXrf//Yr$K9dMJu.rqT/X3U6Lm8FLBIsZnidMyHukURSwJXmqyFu3V9Aq2PRlf3akLscIfFsAgSNTOw6gZNQyLrObg3Qi./";
  };

  environment.sessionVariables = {
    AMD_VULKAN_ICD = "RADV";
  };

  home-manager.users.rb = homeConfig;

  networking.hostName = "montrachet";
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;

  nix.settings.max-jobs = 24;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
    "" # clear old command
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --interface wlan0"
  ];

  #  systemd.services."ddcci@" = {
  #    enable = true;
  #    description = "Force DDCCI to probe after AMDGPU driver is loaded";
  #    unitConfig = {
  #      After = "graphical.target";
  #      Before = "shutdown.target";
  #      Conflicts = "shutdown.target";
  #    };
  #
  #    serviceConfig = {
  #      Type = "oneshot";
  #      ExecStart = ''
  #        ${pkgs.bash}/bin/bash -c 'echo Trying to attach ddcci to %i && success=0 && i=0 && id=$(echo %i | cut -d "-" -f 2) && while ((success < 1)) && ((i++ < 5)); do ${pkgs.ddcutil}/bin/ddcutil getvcp 10 -b $id && { success=1 && echo ddcci 0x37 > /sys/bus/i2c/devices/%i/new_device && echo "ddcci attached to %i"; } || sleep 5; done'
  #      '';
  #      Restart = "no";
  #    };
  #  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ mesa libva ];
  };
  hardware.cpu.amd.updateMicrocode = true;

  services.xserver.videoDrivers = [ "modesetting" ];

  # Needed for nixos-generators to cross compile
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "net.ifnames=0" ];
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "dm-snapshot" "amdgpu" "kvm-amd" "k10temp" "nct6775" "i2c-dev" "uvcvideo" "btusb" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ ]; # ddcci-driver
  boot.extraModprobeConfig = ''
    options ddcci dyndbg delay=400
    options ddcci_backlight dyndbg
  '';

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 1048576;
  };

  boot.initrd.luks.devices = {
    main = {
      device = "/dev/disk/by-partuuid/0d2db233-2104-49a6-a9ef-0f5748fe9989";
      preLVM = true;
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
    options = ["noatime" "nodiratime"];
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
