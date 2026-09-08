{ config, pkgs, ... }:

let
  nextcloudHost = import ../../hosts/viktorPC/nextcloud-host.nix;
in
{
  home.packages = [ pkgs.joplin-desktop ];

  # Seed Joplin's settings.json with Nextcloud sync config, but only once —
  # after that Joplin owns the file and this won't touch it again.
  home.activation.joplinNextcloudSync = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    JOPLIN_CONF="$HOME/.config/joplin-desktop/settings.json"

    if [ ! -f "$JOPLIN_CONF" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$JOPLIN_CONF")"
      $DRY_RUN_CMD cat > "$JOPLIN_CONF" <<EOF
{
  "sync.target": 5,
  "sync.5.path": "https://88.146.116.30/nextcloud/remote.php/dav/files/viktor/Joplin",
  "sync.5.username": "viktor",
  "theme": 2
}
EOF
    fi
  '';
}
