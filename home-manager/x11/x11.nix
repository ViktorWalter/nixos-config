{ hostName, config, ... }:

{

  # Generic X server resources not owned by any specific program module.
  xresources.properties = {
    "Xft.dpi" = {
      viktorPC = 100;
    }.${hostName} or 100;
  };
}
