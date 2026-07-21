{ pkgs, ... }:
{
  programs.htop = {
    enable = true;
    package = pkgs.htop-vim;
    settings = {
      hide_kernel_threads = true;
      hide_userland_threads = true;
    };
  };
}
