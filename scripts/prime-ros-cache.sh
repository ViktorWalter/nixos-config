#!/usr/bin/env bash
# Workaround for the nix.conf chicken-and-egg problem: `nixos-rebuild switch`
# builds the new system closure using the *currently active* nix-daemon
# config, and only installs the new /etc/nix/nix.conf (with the ROS
# substituters from overlays/ros.nix) *after* that build succeeds. So the
# very first rebuild that adds a new substituter can't use it yet, and ends
# up compiling ROS packages from source.
#
# This script seeds /etc/nix/nix.conf with the ROS substituters/keys right
# now, restarts nix-daemon so it's active immediately, then does a
# --dry-run build so you can see whether paths would be fetched (cache hit)
# or built (cache miss) *before* committing to a full, possibly hours-long
# rebuild.
#
# It only touches the live /etc/nix/nix.conf (which nixos-rebuild overwrites
# anyway on the next successful switch); it does not change anything under
# /etc/nixos.
#
# Usage: sudo ./scripts/prime-ros-cache.sh [hostname]
# If hostname is omitted, `hostname` is used (must match a
# nixosConfigurations.<name> in flake.nix, e.g. viktorPC / viktorGPD).

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run this with sudo (needs root to edit nix.conf and restart nix-daemon)." >&2
  exec sudo "$0" "$@"
fi

FLAKE_DIR="/etc/nixos"
HOST="${1:-$(hostname)}"
NIX_CONF="/etc/nix/nix.conf"

SUBSTITUTERS="https://cache.nixos.org/ https://ros.cachix.org https://attic.iid.ciirc.cvut.cz/ros"
TRUSTED_KEYS="cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo= ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q="

echo "== Step 1: seed $NIX_CONF with ROS substituters/keys =="
cp -n "$NIX_CONF" "$NIX_CONF.bak-$(date +%s)" || true

set_conf_key() {
  local key="$1" value="$2"
  if grep -qE "^${key}[[:space:]]*=" "$NIX_CONF"; then
    sed -i "s|^${key}[[:space:]]*=.*|${key} = ${value}|" "$NIX_CONF"
  else
    echo "${key} = ${value}" >>"$NIX_CONF"
  fi
}

set_conf_key "substituters" "$SUBSTITUTERS"
set_conf_key "trusted-public-keys" "$TRUSTED_KEYS"

echo "Updated $NIX_CONF:"
grep -E "^(substituters|trusted-public-keys)" "$NIX_CONF"

echo "== Step 2: restart nix-daemon =="
systemctl restart nix-daemon
sleep 1
systemctl is-active --quiet nix-daemon && echo "nix-daemon is active."

echo "== Step 3: dry-run build for nixosConfigurations.${HOST} =="
nix build \
  "${FLAKE_DIR}#nixosConfigurations.${HOST}.config.system.build.toplevel" \
  --dry-run -L 2>&1 | tee /tmp/opencode/ros-cache-dry-run.log

echo
echo "== Done =="
echo "Look at the output above:"
echo "  - lines like 'these N paths will be fetched' -> good, cache is working"
echo "  - lines like 'these N derivations will be built' -> still a mismatch,"
echo "    e.g. ros-pkgs doesn't match what's published to the cache."
echo
echo "If it looks good, run: sudo nixos-rebuild switch"
