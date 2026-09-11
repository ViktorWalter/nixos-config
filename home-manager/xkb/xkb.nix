{ config, pkgs, ... }:

{
  # The custom symbols fragment, written to ~/.xkb/symbols/custom
  home.file.".xkb/symbols/custom".text = ''
    xkb_symbols "basic" {
      include "pc+us+sk(qwerty):2+inet(evdev)+group(sclk_toggle)+capslock(escape)"

        key <AC10> {
          type[group1]= "TWO_LEVEL",
            type[group2]= "FOUR_LEVEL",
            symbols[Group1]= [ semicolon, colon ],
            symbols[Group2]= [ ocircumflex, quotedbl, uring, dead_doubleacute ]
        };

      key <ESC> {
        symbols[Group1]= [ Escape ],
          symbols[Group2]= [ ISO_First_Group ],
          symbols[Group3]= [ ISO_First_Group ],
          symbols[Group4]= [ ISO_First_Group ]
      };

      key <CAPS> {
        symbols[Group1]= [ Escape ],
          symbols[Group2]= [ ISO_First_Group ],
          symbols[Group3]= [ ISO_First_Group ],
          symbols[Group4]= [ ISO_First_Group ]
      };

      key <RCTL> {
        type[group1]= "THREE_LEVEL",
          type[group2]= "THREE_LEVEL",
          symbols[Group1]= [ NoSymbol, Menu ],
          symbols[Group2]= [ ISO_Last_Group, ISO_Level3_Shift ]
      };

      key <RALT> {
        type[group1]= "ONE_LEVEL",
          type[group2]= "ONE_LEVEL",
          symbols[Group1]= [ Mode_switch ],
          symbols[Group2]= [ Mode_switch ]
      };

      key <LWIN> {
        type[group1]= "ONE_LEVEL",
          symbols[Group1]= [ ISO_Level3_Shift ]
      };
    };
  '';

  home.packages = [
    pkgs.setxkbmap
    pkgs.xkbcomp
  ];

}
