{ config, ... }:
let
  i3Dir = "${config.home.homeDirectory}/.i3";
in
{
  home.file.".themes/Cold Night".source =
    config.lib.file.mkOutOfStoreSymlink "${i3Dir}/theme/Cold Night";

  home.file.".icons/Cold Night".source =
    config.lib.file.mkOutOfStoreSymlink "${i3Dir}/icons/Cold Night";
    
  gtk = {
    enable = true;
    theme.name = "Cold Night";
    iconTheme.name = "Cold Night";
  };

  # Qt apps follow GTK theme (needs qt5ct/qt6ct-style bridging)
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "gtk3";
  };

  services.dunst.settings.global.icon_theme = "Cold Night";

}
