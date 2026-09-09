{ config, pkgs, ... }:

let
  teamsManifestUrl = "https://teams.cloud.microsoft/manifest.json";
  configFile = "${config.home.homeDirectory}/.local/share/firefoxpwa/config.json";
in
{
  home.packages = [ pkgs.firefoxpwa pkgs.jq ];

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.firefoxpwa ];
  };

  home.activation.setupTeamsPwa = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=${pkgs.firefoxpwa}/bin:${pkgs.jq}/bin:$PATH
    CONFIG_FILE="${configFile}"
    MANIFEST_URL="${teamsManifestUrl}"

    # 1. Runtime (skip if it already exists)
    if [ ! -d "${config.home.homeDirectory}/.local/share/firefoxpwa/runtime" ]; then
      echo "Installing firefoxpwa runtime..."
      $DRY_RUN_CMD firefoxpwa runtime install || true
    fi

    if [ -f "$CONFIG_FILE" ]; then
      # 2. Find or create the "Teams" profile
      PROFILE_ID=$(jq -r '.profiles | to_entries[] | select(.value.name=="Teams") | .key' "$CONFIG_FILE" | head -n1)

      if [ -z "$PROFILE_ID" ]; then
        echo "Creating Teams profile..."
        OUT=$($DRY_RUN_CMD firefoxpwa profile create --name "Teams" 2>&1) || true
        echo "$OUT"
        PROFILE_ID=$(jq -r '.profiles | to_entries[] | select(.value.name=="Teams") | .key' "$CONFIG_FILE" | head -n1)
      fi

      if [ -n "$PROFILE_ID" ]; then
        # 3. Skip if a site is already installed in that profile
        SITE_EXISTS=$(jq -r --arg p "$PROFILE_ID" \
          '.sites | to_entries[] | select(.value.profile==$p) | .key' "$CONFIG_FILE" | head -n1)

        if [ -z "$SITE_EXISTS" ]; then
          echo "Installing Teams PWA from $MANIFEST_URL..."
          $DRY_RUN_CMD firefoxpwa site install "$MANIFEST_URL" --profile "$PROFILE_ID" --name "Microsoft Teams" || true
        fi
      fi
    fi
  '';
}
