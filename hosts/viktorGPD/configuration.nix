# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # nixpkgs.overlays = [
  #   (final: prev: {
  #    grub2 = prev.grub2.overrideAttrs (old: {
  #        pname = "grub-rotated";
  #        version = "unstable-2024-06-18";
  #        src = final.fetchFromGitHub {
  #        owner = "kbader94";
  #        repo = "grub";
  #        rev = "main"; # pin to a real commit hash
  #        hash = ""; # nix will report the correct hash on first build
  #        };
  #        patches = [ ];
  #        });
  #    })
  # ];
  #
  # boot.loader.grub.extraConfig = ''
  #   set rotation=90
  # '';
  #

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xrandr}/bin/xrandr --output DSI-1 --rotate right
    ${pkgs.xinput}/bin/xinput set-prop "pointer:Goodix Capacitive TouchScreen" \
      "Coordinate Transformation Matrix" 0 1 0 -1 0 1 0 0 1
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.editor = false;

  #services.upower.enable = true;
  environment.systemPackages = (with pkgs; [
    geteduroam
    tlp
    libgpiod
    python313Packages.gpiod
    brightnessctl 
  ]);

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  boot.kernelModules = [ "coretemp" ];

  # gpd_pocket_fan stays loaded but harmless/deferred - fine to leave or blacklist,
  # your call. Blacklisting avoids the noisy "deferred probe pending" dmesg line:
  boot.blacklistedKernelModules = [ "gpd_pocket_fan" ];

  environment.etc."gpd-fand.py".source = ./gpd-fand.py;

  systemd.services.gpd-fand = {
    description = "GPD Pocket fan control daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.python3.withPackages (ps: [ ps.gpiod ])}/bin/python3 /etc/gpd-fand.py";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  services.udev.packages = [ pkgs.brightnessctl ];
  users.users.viktor.extraGroups = [ "video" ];
}

