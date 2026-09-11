{ hostName, config, pkgs, lib, ... }:
{
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        type = "auto";
      };

      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "shell"
        "display"
        "de"
        "wm"
        "cpu"
        "gpu"
        "memory"
        "disk"
        "packages"
        "break"
        "colors"
      ];
    };
  };

  home.shellAliases.neofetch = "fastfetch";
}
