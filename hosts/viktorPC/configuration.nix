# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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


  #nextcloud config
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = import ./nextcloud-hostname.nix; #ignored by git - should contain the url in quotation marks
    datadir = "/var/lib/nextcloud/data";
    #home = "/var/lib/nextcloud";
    config = {
      dbtype = "sqlite";
      adminpassFile = null; #these will be overriden by imported configs
      adminuser = null;
    };
    settings.apps_paths = [
      {
        path = "${config.services.nextcloud.package}/apps";
        url = "/apps";
        writable = false;
      }
      {
        path = "/var/lib/nextcloud/store-apps";
        url = "/store-apps";
        writable = true;
      }
    ];

    secretFile = "/etc/nextcloud-secrets.json";
  };

  services.nginx.enable = true;

  

  #threema
  services.flatpak.packages = [
    {
      flatpakref = "https://releases.threema.ch/flatpak/threema-desktop/ch.threema.threema-desktop.flatpakref";
      sha256 = "0lghiiiphbkqgiprqirxifldvix0j4k04jh1z9f911shrzjgqq4s"; #get with nix-refetch-url
    }
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = (with pkgs; [
    blender
    prusa-slicer
    kicad
    obsidian
  ]);
}

