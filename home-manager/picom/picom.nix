{ config, pkgs, ... }:

{
  services.picom = {
    enable = true;

    # Rendering backend - "glx" is GPU-accelerated and generally the best choice
    backend = "xrender";
    vSync = true;

    # Shadows
    shadow = false;
    shadowOpacity = 0.6;
    shadowOffsets = [ (-12) (-12) ];
    shadowExclude = [
      "class_g = 'Rofi'"
      "class_g = 'slop'"
      "_GTK_FRAME_EXTENTS@:c"
      "window_type = 'dock'"
      "window_type = 'desktop'"
    ];

    # Fading
    fade = false;
    fadeDelta = 4;
    fadeSteps = [ 0.03 0.03 ];
    fadeExclude = [ ];

    # Opacity
    #activeOpacity = 1.0;
    #inactiveOpacity = 0.9;
    #menuOpacity = 1.0;
    #opacityRules = [
    #  "90:class_g = 'kitty' && focused"
    #  "80:class_g = 'kitty' && !focused"
    #  "100:class_g = 'mpv'"
    #  "100:fullscreen"
    #];

    # Blur (backend must support it - glx or xrender)
    settings = {
      #blur = { # for actuall PC
      #  method = "dual_kawase";
      #  strength = 1;
      #  background = false;
      #  background-frame = false;
      #  background-fixed = false;
      #};

      corner-radius = 0;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];

      # Animations (requires picom-jonaburg or a fork that supports them;
      # the default nixpkgs picom does NOT support these keys - see note below)
      # animations = true;

      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      use-damage = true;
      log-level = "warn";

      wintypes = {
        tooltip = {
          fade = true;
          shadow = false;
          opacity = 0.9;
          focus = true;
        };
        dock = { shadow = false; };
        dnd = { shadow = false; };
        popup_menu = { opacity = 1.0; };
        dropdown_menu = { opacity = 1.0; };
      };
    };
  };
}
