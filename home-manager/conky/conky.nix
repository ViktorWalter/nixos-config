{ config, pkgs, lib, hostName, ... }:

let
  conky124 = pkgs.conky.overrideAttrs (old: rec {
      version = "1.24.2";
  
      src = pkgs.fetchFromGitHub {
        owner = "brndnmtthws";
        repo = "conky";
        rev = "v${version}";
        hash = "sha256-fnH87Ts28t2FIKQkrXjlOFG1NIDPq0JqfDR9aIfog6I=";
      };
      buildInputs = (old.buildInputs or []) ++ [
        pkgs.libXi
      ];
      cmakeFlags = (old.cmakeFlags or []) ++ [
        "-DBUILD_LUA_CAIRO=ON"
        "-DBUILD_LUA_CAIRO_XLIB=ON"
      ];
    });

  conkyConfigDir = "${config.xdg.configHome}/conky";

  conkyDrawConfig = ./conky_draw_config_${hostName}.lua;

  conkyConf = ''
    conky.config = {
      alignment = 'bottom_middle',
      background = false,
      border_width = 0,

      default_color = 'grey',
      default_outline_color = 'white',

      draw_graph_borders = false,
      draw_outline = false,
      draw_shades = false,

      gap_x = 0,
      gap_y = 0,

      minimum_width = 128,
      minimum_height = 50,

      own_window = true,
      own_window_type = 'utility',
      own_window_class = 'conky',
      own_window_transparent = false,
      own_window_hints = 'undecorated,above,skip_taskbar,skip_pager',

      update_interval = 1.0,

      show_graph_scale = false,
      show_graph_range = false,

      lua_load = '${conkyConfigDir}/conky_draw.lua',
      lua_draw_hook_pre = 'main',

      double_buffer = true,
    };

    conky.text = [[
    ]]
  '';

 conkyPositionScript = pkgs.writeShellScript "conky-position" ''
    set -eu

    offset=22

    while true; do
      # Find the primary monitor:
      monitor="$(
        ${pkgs.xrandr}/bin/xrandr --query |
        ${pkgs.gnugrep}/bin/grep ' connected primary ' |
        ${pkgs.gnused}/bin/sed -n \
          's/.* \([0-9][0-9]*\)x\([0-9][0-9]*\)+\(-\?[0-9][0-9]*\)+\(-\?[0-9][0-9]*\).*/\1 \2 \3 \4/p'
      )"

      if [ -n "$monitor" ]; then
        read -r mw mh mx my <<< "$monitor"

        # Find the Conky window.
        window="$(
          ${pkgs.xdotool}/bin/xdotool search \
            --class '^conky$' 2>/dev/null |
          ${pkgs.coreutils}/bin/head -n1 || true
        )"

        if [ -n "$window" ]; then
        # Make sure i3 considers Conky floating.
        ${pkgs.i3}/bin/i3-msg \
          '[class="conky"] floating enable' >/dev/null

          read -r ww wh <<< "$(
            ${pkgs.xdotool}/bin/xdotool getwindowgeometry --shell "$window" |
            ${pkgs.gnugrep}/bin/grep -E '^(WIDTH|HEIGHT)=' |
            ${pkgs.gnused}/bin/sed 's/[^0-9 ]//g' | tr '\n' ' '
          )"

          x=$((mx + (mw) / 2))
          y=$((my + mh - offset))

          ${pkgs.xdotool}/bin/xdotool windowmove "$window" "$x" "$y"
          ${pkgs.xdotool}/bin/xdotool windowraise "$window"
        fi
      fi

      sleep 2
    done
  '';

in {
  home.packages = [
    conky124
    #pkgs.lua
    pkgs.sysstat
  ];

  home.file = {
    ".config/conky/conky.conf".text = conkyConf;

    ".config/conky/conky_draw.lua".source =
      ./conky_draw.lua;

    ".config/conky/conky_draw_config.lua".source =
      conkyDrawConfig;

    ".local/bin/get_amdgpu_load.sh" = {
      source = ./get_amdgpu_load.sh;
      executable = true;
    };
  };

  systemd.user.services.conky = {
    Unit = {
      Description = "Conky system monitor";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${conky124}/bin/conky -c ${conkyConfigDir}/conky.conf";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.conky-position = {
    Unit = {
      Description = "Position Conky on primary monitor";
      After = [ "graphical-session.target" "conky.service" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${conkyPositionScript}";
      Restart = "always";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
