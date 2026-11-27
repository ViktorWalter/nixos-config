{ hostName, pkgs, lib, ... }:
let
  # "none"    -> no battery tray icon at all (e.g. a desktop with no battery)
  # "standard"-> stock cbatticon
  # "patched" -> cbatticon with the GPD Pocket USB-charger AC-detection fix
  cbatticonVariant = {
    "viktorGPD" = "patched";
    "viktorPC" = "none";
  }.${hostName} or "standard";

  cbatticonPackage =
    if cbatticonVariant == "patched" then import ./cbatticon/cbatticon-gpd-pocket.nix { inherit pkgs; }
    else if cbatticonVariant == "standard" then pkgs.cbatticon
    else null;
in
{

  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;

  home.packages = lib.optional (cbatticonPackage != null) cbatticonPackage ++ [ pkgs.pa_applet ];

# pulse audio indicator
  systemd.user.services.pa-applet = {
    Unit = {
      Description = "PulseAudio system tray applet";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.pa_applet}/bin/pa-applet";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

#battery indicator
  systemd.user.services.cbatticon = lib.mkIf (cbatticonPackage != null) {
    Unit = {
      Description = "Battery tray icon"
        + lib.optionalString (cbatticonVariant == "patched") " (patched for GPD Pocket's USB-type charger)";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${cbatticonPackage}/bin/cbatticon -i standard -u 5";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
