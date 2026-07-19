{ pkgs, ... }:

{
  home.packages = [ pkgs.terminus_font ];
  fonts.fontconfig.enable = true;

  programs.urxvt = {
    enable = true;

    fonts = [
      "xft:Terminus:size=10"
    ];
    

    iso14755 = false;

    scroll = {
      bar.enable = false;
      # Your original file had "URxvt.saveLine: 10000" (singular). The real
      # X resource urxvt reads is "saveLines" (plural) -- so that line was
      # very likely a silent no-op already. This option generates the
      # correctly-spelled resource, so it'll actually take effect now.
      lines = 10000;
    };

    keybindings = {
      # font resizing
      "C-minus" = "resize-font:smaller";
      "C-plus" = "resize-font:bigger";
      "C-equal" = "resize-font:reset";
      "C-question" = "resize-font:show";

      # shared clipboard
      "Shift-Control-V" = "perl:clipboard:paste";

      # fix CTRL+SHIFT+P
      "Shift-Control-P" = "\\033[24;5~";

      # fix CTRL+0 ... CTRL+9
      "Control-1" = "\\033[27;5;49~";
      "Control-2" = "\\033[27;5;50~";
      "Control-3" = "\\033[27;5;51~";
      "Control-4" = "\\033[27;5;52~";
      "Control-5" = "\\033[27;5;53~";
      "Control-6" = "\\033[27;5;54~";
      "Control-7" = "\\033[27;5;55~";
      "Control-8" = "\\033[27;5;56~";
      "Control-9" = "\\033[27;5;57~";
      "Control-0" = "\\033[27;5;48~";
    };

    # Everything without a dedicated programs.urxvt.* option (colors,
    # background/foreground, depth, visualBell, perl extensions) goes here.
    # Each key is automatically written out as "URxvt.<key>".
    extraConfig = {
      "perl-ext-common" = "default,clipboard";

      background = "rgba:0000/0000/0000/cccc";
      foreground = "#00bffa";

      color0 = "#1C1C1C";
      color8 = "#404040";
      color1 = "#B85335"; # red
      color9 = "#CF6A4C";
      color2 = "#79AD6A"; # green
      color10 = "#99DD6A";
      color3 = "#FFB964"; # yellow
      color11 = "#FAD07A";
      color4 = "#667899"; # blue
      color12 = "#8197BF";
      color5 = "#A7A7FF"; # magenta
      color13 = "#C6B6EE";
      color6 = "#668799"; # cyan
      color14 = "#8FBFDC";
      color7 = "#888888"; # white
      color15 = "#FFFFFF";

      # Originally "URxvt*depth" / "URxvt*visualBell" (loose bindings, `*`).
      # This option always emits tight bindings ("URxvt.depth" etc.), which
      # is functionally equivalent here since nothing else contends for
      # these resource names.
      depth = 32;
      visualBell = false;
    };
  };

}
