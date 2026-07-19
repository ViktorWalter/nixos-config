{ config, ... }:

{
  programs.rofi = {
    enable = true;

    # Directly-portable settings.
    extraConfig = {
      show-icons = true;
      "drun-icon-theme" = "Papirus-Dark";
      "run-command" = "i3 exec {cmd}";
    };

    # Reconstructed color scheme -- see the big comment at the top of this
    # file for why this isn't a strict 1:1 port of the old color-* lines.
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
        # background-alt colors in your original were fully transparent
        # (alpha 00) in every state except urgent's selected row -- kept
        # that pattern here.
        transparentAlt = mkLiteral "rgba(39, 50, 56, 0%)";
      in
      {
        "*" = {
          background-color = mkLiteral "rgba(0, 0, 0, 87%)"; # was argb:dd000000
          border-color = mkLiteral "#273238";
          separatorcolor = mkLiteral "#1e2529";

          normal-background = transparentAlt;
          normal-foreground = mkLiteral "#00bffa";
          alternate-normal-background = transparentAlt;
          selected-normal-background = mkLiteral "#00bffa";
          selected-normal-foreground = mkLiteral "#000000";

          active-background = transparentAlt;
          active-foreground = mkLiteral "#80cbc4";
          alternate-active-background = transparentAlt;
          selected-active-background = mkLiteral "#00bffa";
          selected-active-foreground = mkLiteral "#000000";

          urgent-background = transparentAlt;
          urgent-foreground = mkLiteral "#ff1844";
          alternate-urgent-background = transparentAlt;
          selected-urgent-background = mkLiteral "#394249";
          selected-urgent-foreground = mkLiteral "#ff1844";
        };
      };
  };
}
