{ pkgs, athame-flake }:
let
  zsh588 = pkgs.zsh.overrideAttrs (old: rec {
      version = "5.8";
      src = pkgs.fetchurl {
        url = "https://www.zsh.org/pub/zsh-${version}.tar.xz";
        sha256 = "sha256-3MS1TMVWVnCmVYF2AmHBY9cgmR8NBkhtph+Ng5tS3ic=";
      };
      #NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration";
    });

  athameZsh = pkgs.callPackage "${athame-flake}/zsh-athame.nix" {
    inherit (athame-flake.inputs) athame vimbed;
    zsh = zsh588;
    # zsh = pkgs.zsh;
    neovim = pkgs.neovim;
  };
in
  athameZsh
