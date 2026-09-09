{ config, pkgs, lib, ... }:

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

      gap_x = 400,
      gap_y = 1,

      minimum_width = 120,
      minimum_height = 20,

      own_window = true,
      own_window_type = 'normal',
      own_window_class = 'conky',
      own_window_transparent = false,
      own_window_hints = 'undecorated,below,skip_taskbar,skip_pager',

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
      ./conky_draw_config.lua;

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
}
