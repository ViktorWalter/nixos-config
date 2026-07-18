{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    package = pkgs.athame-zsh;

    autosuggestion.enable = false;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases = {
      ll = "ls -la";
      vim = "nvim";
      sb = "source ~/.zshrc";
      update = "sudo nixos-rebuild switch";
    };

    localVariables = {
      USE_ATHAME = true;
    };

    oh-my-zsh = { # "ohMyZsh" without Home Manager
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  home.file.".athamerc".text = ''
    source /etc/athamerc
  '';

  imports = [
    #./home-manager/neovim.nix
    ./home-manager/i3.nix
  ];
}
