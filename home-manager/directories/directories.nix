{ config, ... }:

{
  home.file."Documents".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/SSD_S/Documents";
  home.file."Pictures".source =  config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/SSD_S/Pictures";
  home.file."Downloads".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/SSD_S/Downloads";
  home.file."Videos".source =    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/SSD_S/Videos";
  home.file."Music".source =     config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/HDD_X/Music";

  xdg.userDirs = {
    enable = true;
    createDirectories = false; # home.file already manages these as symlinks

    documents = "${config.home.homeDirectory}/Documents";
    download  = "${config.home.homeDirectory}/Downloads";
    music     = "${config.home.homeDirectory}/Music";
    pictures  = "${config.home.homeDirectory}/Pictures";
    videos    = "${config.home.homeDirectory}/Videos";

    extraConfig = {
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
  };
}
