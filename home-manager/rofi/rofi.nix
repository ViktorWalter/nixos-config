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
      in
      {
        "*" = {
          foreground = mkLiteral "rgba(0, 191, 250, 100%)";
          background = mkLiteral "rgba(0, 0, 0, 87%)";
          background-color = mkLiteral "var(background)";
          red = mkLiteral "rgba(220, 50, 47, 100%)";
          blue = mkLiteral "rgba(38, 139, 210, 100%)";
          lightbg = mkLiteral "rgba(238, 232, 213, 100%)";
          lightfg = mkLiteral "rgba(88, 104, 117, 100%)";
          spacing = 2;

          normal-foreground = mkLiteral "var(foreground)";
          active-foreground = mkLiteral "rgba(128, 203, 196, 100%)";
          urgent-foreground = mkLiteral "rgba(255, 24, 68, 100%)";

          selected-normal-foreground = mkLiteral "rgba(0, 0, 0, 100%)";
          selected-active-foreground = mkLiteral "rgba(0, 0, 0, 100%)";
          selected-urgent-foreground = mkLiteral "rgba(255, 24, 68, 100%)";

          alternate-normal-foreground = mkLiteral "var(foreground)";
          alternate-active-foreground = mkLiteral "var(active-foreground)";
          alternate-urgent-foreground = mkLiteral "var(urgent-foreground)";

          normal-background = mkLiteral "rgba(39, 50, 56, 0%)";
          active-background = mkLiteral "rgba(39, 50, 56, 0%)";
          urgent-background = mkLiteral "rgba(39, 50, 56, 0%)";

          selected-normal-background = mkLiteral "rgba(0, 191, 250, 100%)";
          selected-active-background = mkLiteral "rgba(0, 191, 250, 100%)";
          selected-urgent-background = mkLiteral "rgba(57, 66, 73, 100%)";

          alternate-normal-background = mkLiteral "rgba(39, 50, 56, 0%)";
          alternate-active-background = mkLiteral "rgba(39, 50, 56, 0%)";
          alternate-urgent-background = mkLiteral "rgba(39, 50, 56, 0%)";

          separatorcolor = mkLiteral "rgba(30, 37, 41, 100%)";
          border-color = mkLiteral "rgba(39, 50, 56, 100%)";
        };

        "window" = {
          padding = 5;
          background-color = mkLiteral "var(background)";
          border = 1;
        };

        "mainbox" = {
          padding = 0;
          border = 0;
        };

        "message" = {
          padding = mkLiteral "1px";
          border-color = mkLiteral "var(separatorcolor)";
          border = mkLiteral "2px dash 0px 0px";
        };

        "textbox" = {
          text-color = mkLiteral "var(foreground)";
        };

        "listview" = {
          padding = mkLiteral "2px 0px 0px";
          scrollbar = true;
          border-color = mkLiteral "var(separatorcolor)";
          spacing = mkLiteral "2px";
          fixed-height = 0;
          border = mkLiteral "2px dash 0px 0px";
        };

        "element" = {
          padding = mkLiteral "1px";
          border = 0;
        };

        "element-text" = {
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        "element normal.normal" = {
          background-color = mkLiteral "var(normal-background)";
          text-color = mkLiteral "var(normal-foreground)";
        };
        "element normal.urgent" = {
          background-color = mkLiteral "var(urgent-background)";
          text-color = mkLiteral "var(urgent-foreground)";
        };
        "element normal.active" = {
          background-color = mkLiteral "var(active-background)";
          text-color = mkLiteral "var(active-foreground)";
        };
        "element selected.normal" = {
          background-color = mkLiteral "var(selected-normal-background)";
          text-color = mkLiteral "var(selected-normal-foreground)";
        };
        "element selected.urgent" = {
          background-color = mkLiteral "var(selected-urgent-background)";
          text-color = mkLiteral "var(selected-urgent-foreground)";
        };
        "element selected.active" = {
          background-color = mkLiteral "var(selected-active-background)";
          text-color = mkLiteral "var(selected-active-foreground)";
        };
        "element alternate.normal" = {
          background-color = mkLiteral "var(alternate-normal-background)";
          text-color = mkLiteral "var(alternate-normal-foreground)";
        };
        "element alternate.urgent" = {
          background-color = mkLiteral "var(alternate-urgent-background)";
          text-color = mkLiteral "var(alternate-urgent-foreground)";
        };
        "element alternate.active" = {
          background-color = mkLiteral "var(alternate-active-background)";
          text-color = mkLiteral "var(alternate-active-foreground)";
        };

        "scrollbar" = {
          width = mkLiteral "4px";
          padding = 0;
          handle-width = mkLiteral "8px";
          border = 0;
          handle-color = mkLiteral "var(normal-foreground)";
        };

        "mode-switcher" = {
          border-color = mkLiteral "var(separatorcolor)";
          border = mkLiteral "2px dash 0px 0px";
        };

        "button" = {
          spacing = 0;
          text-color = mkLiteral "var(normal-foreground)";
        };
        "button selected" = {
          background-color = mkLiteral "var(selected-normal-background)";
          text-color = mkLiteral "var(selected-normal-foreground)";
        };

        "inputbar" = {
          padding = mkLiteral "1px";
          spacing = mkLiteral "0px";
          text-color = mkLiteral "var(normal-foreground)";
          children = mkLiteral "[ prompt,textbox-prompt-colon,entry,overlay,case-indicator ]";
        };

        "case-indicator" = {
          spacing = 0;
          text-color = mkLiteral "var(normal-foreground)";
        };

        "entry" = {
          spacing = 0;
          text-color = mkLiteral "var(normal-foreground)";
        };

        "prompt" = {
          spacing = 0;
          text-color = mkLiteral "var(normal-foreground)";
        };

        "textbox-prompt-colon" = {
          margin = mkLiteral "0px 0.3000em 0.0000em 0.0000em";
          expand = false;
          str = ":";
          text-color = mkLiteral "inherit";
        };

        "error-message" = {
          background-color = mkLiteral "rgba(0, 0, 0, 0%)";
          text-color = mkLiteral "var(normal-foreground)";
        };
      };
  };
}

