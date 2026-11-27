#!/usr/bin/env bash
# Run this once, right after placing this repo at /etc/nixos (e.g. on a
# fresh NixOS install), to prime the ROS binary caches before the install
# builds the system, then perform the install itself.
#
# Without this, the very first build would compile all of ROS from source:
# see scripts/prime-ros-cache.sh for why.
#
# Usage: ./scripts/first_build.sh <hostName>
#   hostName must match one of the nixosConfigurations defined in flake.nix
#   (currently: viktorPC, viktorGPD).

set -euo pipefail

FLAKE_DIR="/etc/nixos"
SCRIPT_DIR="${FLAKE_DIR}/scripts"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <hostName>" >&2
  echo "  e.g. $0 viktorPC" >&2
  exit 1
fi

hostName="$1"

if ! grep -qE "\\b${hostName}\\b[[:space:]]*=[[:space:]]*mkHost" "${FLAKE_DIR}/flake.nix"; then
  echo "Warning: '${hostName}' was not found as a nixosConfiguration in flake.nix." >&2
  read -r -p "Continue anyway? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || exit 1
fi

"${SCRIPT_DIR}/prime-ros-cache.sh" "${hostName}"

sudo nixos-install --flake "${FLAKE_DIR}#${hostName}"
