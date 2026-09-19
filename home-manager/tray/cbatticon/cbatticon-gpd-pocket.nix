# home-manager/tray/cbatticon-gpd-pocket.nix
#
# Returns cbatticon patched so its AC-detection also recognizes USB-type
# charger power supplies (e.g. bq24190-charger on the GPD Pocket), not just
# Mains. Without this, the max17042 fuel gauge's "status" sysfs attribute is
# permanently stuck on "Unknown" because nothing links it to the charger IC.
{ pkgs }:

pkgs.cbatticon.overrideAttrs (old: {
  pname = "cbatticon-gpd-pocket";
  patchPhase = ''
    ${old.patchPhase or ""}
    patch -p1 < ${./cbatticon-gpd-pocket-usb-ac.patch}
  '';
})
