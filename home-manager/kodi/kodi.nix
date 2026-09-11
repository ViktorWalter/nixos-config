{ config, pkgs, ... }:

let
  kodiPackages = pkgs.kodiPackages;

  elementum = pkgs.callPackage ./elementum {
    buildKodiAddon = kodiPackages.buildKodiAddon;
  };

  elementumBurst = pkgs.callPackage ./elementum-burst {
    buildKodiAddon = kodiPackages.buildKodiAddon;
  };

  kodiWithElementum = pkgs.kodi.withPackages (kodi: [
    elementum
    elementumBurst
    kodi.kodi-six
    kodi.requests
    kodi.future
  ]);
in
{
  home.packages = [
    kodiWithElementum
  ];
}
