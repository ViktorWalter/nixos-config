{ hostName, pkgs, lib, ... }:
let
  battindicatorHosts = [ "viktorGPD" "viktorTP" ];
  enableBattindicator = builtins.elem hostName battindicatorHosts;
  cbatticon-gpd-pocket = pkgs.cbatticon.overrideAttrs (old: {
    pname = "cbatticon-gpd-pocket";
    patchPhase = ''
      ${old.patchPhase or ""}
      patch -p1 < ${./cbatticon/cbatticon-gpd-pocket-usb-ac.patch}
    '';
  });
in
{

  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;
  services.pasystray = {
    enable = true;
    extraOptions = [
      "-g"
    ];
  };


home.packages = [ cbatticon-gpd-pocket ];

  systemd.user.services.cbatticon = {
    Unit = {
      Description = "Battery tray icon (patched for GPD Pocket's USB-type charger)";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${cbatticon-gpd-pocket}/bin/cbatticon -i symbolic -u 5";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
