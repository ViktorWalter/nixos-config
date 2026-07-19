{ pkgs, ... }:
{
  imports = [
    ./home-manager/zsh/zsh.nix
    ./home-manager/nvim/neovim.nix
    ./home-manager/i3/i3.nix
  ];
}
