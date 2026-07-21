{ hostName, athame-flake, config, pkgs, lib, ... }:
{
  programs.hyfetch = { #maintained neofetch fork
    enable = true;
    settings = {
      preset = "leather";
      mode = "rgb";
      auto_detect_light_dark = false;
      light_dark = "dark";
      lightness = 0.56;
      color_align = {
          mode = "custom";
          custom_colors = {
              "1" = 1;
              "2" = 2;
          };
      };
      pride_month_disable = true; #some animation
      backend = "neofetch";
    };
  };
}
