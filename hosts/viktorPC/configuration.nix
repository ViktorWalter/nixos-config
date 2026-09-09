# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nextcloud.nix
    ];

  networking.hostName = "viktorPC";

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true; 
  boot.loader.grub.extraEntries = ''
    menuentry "Windows 10" {
      insmod part_msdos
      insmod ntfs
      insmod chain
      set root=(hd0,1)
      chainloader +1
    }
  '';

  swapDevices = [
    { device = "/swapfile"; size = 8192; } 
  ];

  #Drive mounting 
  fileSystems."/home/viktor/HDD_X" = {
    device = "/dev/disk/by-uuid/0D99011D4D257278";
    fsType = "ntfs";
    options = [
      "nofail"
    ];
  };
  fileSystems."/home/viktor/HDD_Y" = {
    device = "/dev/disk/by-uuid/19AE099C2CFFA419";
    fsType = "ntfs";
    options = [
      "nofail"
    ];
  };
  fileSystems."/home/viktor/SSD_S" = {
    device = "/dev/disk/by-uuid/44D5B4C74B893D51";
    fsType = "ntfs";
    options = [
      "nofail"
    ];
  };
  fileSystems."/home/viktor/Win_DATA" = {
    device = "/dev/disk/by-uuid/D06873F66873D9A4";
    fsType = "ntfs";
    options = [
      "nofail"
    ];
  };


  #threema
  services.flatpak.packages = [
    {
      flatpakref = "https://releases.threema.ch/flatpak/threema-desktop/ch.threema.threema-desktop.flatpakref";
      sha256 = "0lghiiiphbkqgiprqirxifldvix0j4k04jh1z9f911shrzjgqq4s"; #get with nix-refetch-url
    }
  ];
  #to allow threema to store keys and allow persistant login
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true; # or whatever your login PAM service is called (e.g. "sddm", "gdm", "greetd")

  nixpkgs.config.allowUnfree = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  environment.systemPackages = (with pkgs; [
    blender
    prusa-slicer
    kicad
    obsidian
    btop-rocm
  ]);
}

