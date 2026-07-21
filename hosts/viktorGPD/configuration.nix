# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.overlays = [
    (final: prev: {
     grub2 = prev.grub2.overrideAttrs (old: {
         pname = "grub-rotated";
         version = "unstable-2024-06-18";
         src = final.fetchFromGitHub {
         owner = "kbader94";
         repo = "grub";
         rev = "main"; # pin to a real commit hash
         hash = ""; # nix will report the correct hash on first build
         };
         patches = [ ];
         });
     })
  ];

  boot.loader.grub.extraConfig = ''
    set rotation=90
  '';


  networking.hostName = "viktorGPD";

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xrandr}/bin/xrandr --output DSI-1 --rotate right
  '';

  environment.systemPackages = with pkgs; [
    cbatticon
  ];
}

