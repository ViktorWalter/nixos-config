{ config, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Viktor Walter";
        email = "viktor.walter@disroot.org";
      };
    };
  };
}

