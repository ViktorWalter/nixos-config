{ hostName, config, pkgs, ... }:
{
  imports = [
    ./home-manager/zsh/zsh.nix
    ./home-manager/nvim/neovim.nix
    ./home-manager/i3/i3.nix
    ./home-manager/urxvt/urxvt.nix
    ./home-manager/rofi/rofi.nix
    ./home-manager/x11/x11.nix
  ];
}
