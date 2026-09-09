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
        "uptime"
        "shell"
        "display"
        "de"
        "wm"
        "terminal"
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
