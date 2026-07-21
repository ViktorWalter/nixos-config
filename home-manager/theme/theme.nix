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
    cursorTheme = {
      name = "Cold Night";   # or a separate cursor-theme name if it's distinct
        size = 24;
    };
  };

  # Qt apps follow GTK theme (needs qt5ct/qt6ct-style bridging)
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "gtk3";
  };

  # X11 cursor (covers non-GTK/Qt apps, i3 itself, root window cursor)
  home.pointerCursor = {
    name = "Cold Night";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Cold Night";
    XCURSOR_SIZE = "24";
  };
}
