{ hostName, pkgs, lib, ... }:
let
  cbatticonHosts = [ "viktorGPD" "viktorTP" ];
  enableCbatticon = builtins.elem hostName cbatticonHosts;
in
{
  systemd.user.services = {
    nm-applet = {
      Unit = {
        Description = "Network Manager Applet";
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service.ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    };

    blueman-applet = {
      Unit = {
        Description = "Blueman Applet";
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service.ExecStart = "${pkgs.blueman}/bin/blueman-applet";
    };

    pasystray = {
      Unit = {
        Description = "PulseAudio Tray Icon";
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service.ExecStart = "${pkgs.pasystray}/bin/pasystray";
    };
  } // lib.optionalAttrs enableCbatticon { #so that we don't use it on a desktop

    cbatticon = {
      Unit = {
        Description = "Battery Tray Icon";
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service.ExecStart = "${pkgs.cbatticon}/bin/cbatticon";
    };
  };
}
