{ config, ... }:

{
  home.file."Documents".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/SSD_S/Documents";
  home.file."Pictures".source =  config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/SSD_S/Pictures";
  home.file."Downloads".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/SSD_S/Downloads";
  home.file."Videos".source =    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/SSD_S/Videos";
}
