{ hostName, athame-flake, config, pkgs, lib, ... }:
{
  imports = [
    ./home-manager/zsh/zsh.nix
    ./home-manager/nvim/nvim.nix
    ./home-manager/i3/i3.nix
    ./home-manager/theme/theme.nix
    ./home-manager/urxvt/urxvt.nix
    ./home-manager/rofi/rofi.nix
    ./home-manager/x11/x11.nix
    ./home-manager/tray/tray.nix
    ./home-manager/tmux/tmux.nix
    ./home-manager/git/git.nix
    ./home-manager/other/other.nix
    ./home-manager/neofetch/neofetch.nix
  ]
++ lib.optionals  (lib.strings.trim hostName == "viktorPC") [
  ./home-manager/picom/picom.nix
];
}
