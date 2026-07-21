{ hostName, pkgs, lib, ... }:
let
  cbatticonHosts = [ "viktorGPD" "viktorTP" ];
  enableCbatticon = builtins.elem hostName cbatticonHosts;
in
{

  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;
  services.pasystray.enable = true;

  services.cbatticon = {
    enable = enableCbatticon;
  # optional extras, e.g.:
  # iconType = "symbolic";
  # lowLevelPercent = 20;
  # criticalLevelPercent = 5;
  };

}
