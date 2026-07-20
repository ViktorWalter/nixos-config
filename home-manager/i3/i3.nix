{ hostName, config, pkgs, lib, ... }:
let
  here = toString ./.;
in
{
  home.packages = [ pkgs.font-awesome ];
  home.file.".i3" = {
    source = ./doti3;
    recursive = false;
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;

    # Raw config below replaces home-manager's generated config entirely.
    config = null;

    extraConfig = ''
      # i3 config file (v4)
      exec --no-startup-id /usr/lib/x86_64-linux-gnu/xfce4/notifyd/xfce4-notifyd

      exec --no-startup-id ssh-agent
      exec --no-startup-id nm-applet
      exec --no-startup-id blueman-applet
      exec --no-startup-id "sleep 2;  pulseaudio --start"
      exec --no-startup-id "sleep 3; pa-applet"
      exec --no-startup-id cbatticon
      exec_always  --no-startup-id  ~/.i3/my_autoname_workspaces.py &
      exec_always  --no-startup-id ~/.i3/conky/conky_start
      exec_always  --no-startup-id "unclutter -idle 3"
      exec_always  --no-startup-id "sleep 2; ~/.i3/border_control"

      exec_always  --no-startup-id "sleep 2; keynav"

      exec_always  "~/.screenlayout/dual_uw.sh"

      set $mod Mod1
      set $mod2 Mod3
      set $mod3 Mod5
      set $mod4 Mod4

      font pango:Terminus, Font Awesome 7 Free 9

      # Use Mouse+$mod to drag floating windows to their wanted position
      floating_modifier $mod

      # start a terminal
      bindsym $mod+Return exec urxvt

      # kill focused window
      bindsym $mod+Shift+q kill

      # mouse will no longer change focus when pointing on a window
      focus_follows_mouse no

      # for when we need a shortcut that i3 has overwritten
      mode "pass-through" {
          bindsym Escape mode "default"
      }
      bindsym $mod+i mode "pass-through"

      # changing focus of a window
      bindsym $mod+h focus left
      bindsym $mod+j focus down
      bindsym $mod+k focus up
      bindsym $mod+l focus right

      # move focused window
      bindsym $mod+Shift+h move left
      bindsym $mod+Shift+j move down
      bindsym $mod+Shift+k move up
      bindsym $mod+Shift+l move right

      # wifi menu
      bindsym $mod3+w exec networkmanager_dmenu
      # audio menu
      bindsym $mod3+v exec "~/.i3/detacher.sh '~/.i3/set_fake_outputs.sh'"
      bindsym $mod3+y exec ~/git/linux-setup/submodules/i3-layout-manager/layout_manager.sh
      bindsym $mod3+n exec ~/.i3/setSink.sh

      # move workspace to another monitor
      bindsym $mod+x move workspace to output right

      # cycle through containers on the current workspace, window-like
      bindsym Mod1+Tab focus right

      # split orientation
      bindsym $mod+braceright split h
      bindsym $mod+braceleft split v

      # fullscreen
      bindsym $mod+f fullscreen

      # container layout
      bindsym $mod+s layout stacking
      bindsym $mod+w layout tabbed
      bindsym $mod+e layout toggle split

      # toggle tiling / floating
      bindsym $mod+Shift+space floating toggle

      # change focus between tiling / floating windows
      bindsym $mod+space focus mode_toggle

      # focus the parent / child container
      bindsym $mod+a focus parent
      bindsym $mod+Shift+a focus child

      # No fake outputs (JELLYBEANS / default branch; the FAKEOUTPUTS_16_9,
      # FAKEOUTPUTS_4_3 and FAKEOUTPUTS_1_1 xrandr layouts from your source
      # file were dropped here -- see note 1 above)

      # workspace names
      set $workspace1 "1"
      set $workspace2 "2"
      set $workspace3 "3"
      set $workspace4 "4"
      set $workspace5 "5"
      set $workspace6 "6"
      set $workspace7 "7"
      set $workspace8 "8"
      set $workspace9 "9"
      set $workspace10 "10"

      # switch to workspace
      bindsym $mod+1 workspace number 1
      bindsym $mod+2 workspace number 2
      bindsym $mod+3 workspace number 3
      bindsym $mod+4 workspace number 4
      bindsym $mod+5 workspace number 5
      bindsym $mod+6 workspace number 6
      bindsym $mod+7 workspace number 7
      bindsym $mod+8 workspace number 8
      bindsym $mod+9 workspace number 9
      bindsym $mod+0 workspace number 10

      # move focused container to workspace
      bindsym $mod+Shift+1 move container to workspace number 1
      bindsym $mod+Shift+2 move container to workspace number 2
      bindsym $mod+Shift+3 move container to workspace number 3
      bindsym $mod+Shift+4 move container to workspace number 4
      bindsym $mod+Shift+5 move container to workspace number 5
      bindsym $mod+Shift+6 move container to workspace number 6
      bindsym $mod+Shift+7 move container to workspace number 7
      bindsym $mod+Shift+8 move container to workspace number 8
      bindsym $mod+Shift+9 move container to workspace number 9
      bindsym $mod+Shift+0 move container to workspace number 10

      # reload / restart / exit
      bindsym $mod+Shift+c reload
      bindsym $mod+Shift+r restart
      bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"

      # resize mode
      mode "resize" {
        bindsym h resize shrink width 10 px or 10 ppt
        bindsym j resize grow height 10 px or 10 ppt
        bindsym k resize shrink height 10 px or 10 ppt
        bindsym l resize grow width 10 px or 10 ppt

        bindsym Left resize shrink width 10 px or 10 ppt
        bindsym Down resize grow height 10 px or 10 ppt
        bindsym Up resize shrink height 10 px or 10 ppt
        bindsym Right resize grow width 10 px or 10 ppt

        bindsym Return mode "default"
        bindsym Escape mode "default"
      }
      bindsym $mod+r mode "resize"

      # JELLYBEANS color scheme (the LIGHT scheme from your source file was
      # commented out there and is dropped here -- see note 1 above)
      set $focused_ws_bg            #00bffa
      set $active_text_color        #ffffff
      set $inactive_text_color      #eeeeee
      set $inactive_background      #333333
      set $active_background        #005faf
      set $background_color         #151515
      set $active_border            #005faf
      set $split_indicator          #B85335
      set $transparent              #000000dd
      set $text_color               #005faf

      exec_always --no-startup-id ~/.i3/setWallpaper.sh

      for_window [class="^.*"] border pixel 2
      for_window [class="conky"] border none

      # window colors
      #                       border                    background            text                  indicator
      client.focused          $focused_ws_bg            $focused_ws_bg        $active_text_color    $split_indicator
      client.unfocused        $inactive_background      $inactive_background  $inactive_text_color  $split_indicator
      client.focused_inactive $active_background        $active_background    $inactive_text_color  $split_indicator
      client.urgent           $inactive_background      $inactive_background  $inactive_text_color  $split_indicator

      # show popups belonging to current fullscreen window
      popup_during_fullscreen smart

      for_window [class="dock"] floating enable
      for_window [class="desktop"] floating enable
      for_window [class="conky"] floating enable
      for_window [class="conky"] sticky enable
      for_window [class="conky"] no_focus
      for_window [class="conky"] move to output primary


      for_window [class="firefox"] move to workspace number 5


      # gaps
      gaps inner 5
      gaps outer 1
      smart_gaps on
      smart_borders on

      # rofi launcher
      bindsym $mod+d exec "rofi -combi-modi drun,run -show combi -modi combi -location 2 -terminal urxvt -font 'Terminus Bold 15'"

      # Pulse Audio controls
      bindsym --release $mod+Insert exec --no-startup-id xdotool key --clearmodifiers XF86AudioRaiseVolume
      bindsym --release $mod+Delete exec --no-startup-id xdotool key --clearmodifiers XF86AudioLowerVolume
      bindsym --release $mod+BackSpace exec --no-startup-id xdotool key --clearmodifiers XF86AudioMute
      bindsym --release $mod4+Insert exec --no-startup-id xdotool key --clearmodifiers XF86AudioRaiseVolume
      bindsym --release $mod4+Delete exec --no-startup-id xdotool key --clearmodifiers XF86AudioLowerVolume
      bindsym --release $mod4+BackSpace exec --no-startup-id xdotool key --clearmodifiers XF86AudioMute

      # screen brightness
      bindsym $mod+F1 exec xbacklight -dec 10
      bindsym $mod+F3 exec xbacklight -set 0
      bindsym $mod+F4 exec xbacklight -set 100

      bindsym $mod+Shift+p exec ~/.i3/swapLayout.sh
      bindsym $mod+Shift+o exec ~/.i3/externOnly.sh

      # swapping keyboard layouts
      exec_always --no-startup-id ~/.i3/setKeyboard.sh

      # lock session
      bindsym $mod+Shift+x exec ~/.i3/shutdown_menu -p rofi

      # invert screen color
      bindsym $mod+Ctrl+i exec ~/git/xrandr-invert-colors/xrandr-invert-colors.bin

      # printscreen
      bindsym Print exec shutter --select

      mode "longpress" {
        # fast drag
        bindsym ctrl+h exec --no-startup-id xdotool mousemove_relative --sync -- -$fast 0
        bindsym ctrl+j exec --no-startup-id xdotool mousemove_relative --sync -- 0 $fast
        bindsym ctrl+k exec --no-startup-id xdotool mousemove_relative --sync -- 0 -$fast
        bindsym ctrl+l exec --no-startup-id xdotool mousemove_relative --sync -- $fast 0
        # slow drag
        bindsym h exec --no-startup-id xdotool mousemove_relative --sync -- -$slow 0
        bindsym j exec --no-startup-id xdotool mousemove_relative --sync -- 0 $slow
        bindsym k exec --no-startup-id xdotool mousemove_relative --sync -- 0 -$slow
        bindsym l exec --no-startup-id xdotool mousemove_relative --sync -- $slow 0

        bindsym Escape exec --no-startup-id xdotool mouseup 1; mode "default"
      }

      mode "mouse" {
        # slow move
        bindsym h exec --no-startup-id xdotool mousemove_relative --sync -- -10 0
        bindsym j exec --no-startup-id xdotool mousemove_relative --sync -- 0 10
        bindsym k exec --no-startup-id xdotool mousemove_relative --sync -- 0 -10
        bindsym l exec --no-startup-id xdotool mousemove_relative --sync -- 10 0

        # fast move
        bindsym shift+h exec --no-startup-id xdotool mousemove_relative --sync -- -25 0
        bindsym shift+j exec --no-startup-id xdotool mousemove_relative --sync -- 0 25
        bindsym shift+k exec --no-startup-id xdotool mousemove_relative --sync -- 0 -25
        bindsym shift+l exec --no-startup-id xdotool mousemove_relative --sync -- 25 0

        bindsym $mod+h focus left
        bindsym $mod+j focus down
        bindsym $mod+k focus up
        bindsym $mod+l focus right

        bindsym f exec --no-startup-id xdotool click 1
        bindsym d exec --no-startup-id xdotool click 3
        bindsym u exec --no-startup-id xdotool click 1
        bindsym i exec --no-startup-id xdotool click 3

        bindsym $mod+n workspace next_on_output
        bindsym $mod+m workspace prev_on_output

        bindsym Escape mode "default"
        bindsym r exec --no-startup-id xdotool mousedown 1; mode "longpress"

        # banish the mouse pointer to the corner of the current window
        bindsym b exec --no-startup-id ~/.i3/banishMouse.sh
      }
      bindsym $mod+c mode "mouse"

      set $slow 10
      set $fast 100

      bindsym $mod+minus scratchpad show
      bindsym $mod+Shift+minus move scratchpad

      bindsym $mod3+b exec --no-startup-id ~/.i3/banishMouse.sh
      bindsym $mod4+r exec ~/.i3/setKeyboard.sh
      # bindsym $mod+t exec "sudo ~/.i3/startTickeys.sh"
      # bindsym $mod+g exec "sudo ~/.i3/startTickeys.sh stop"
      #

      include ~/.my.i3.config
    '';
  };

  # make the additionall zshrc editable from home
  home.file.".my.i3.config".source = 
    config.lib.file.mkOutOfStoreSymlink
    "${here}/${hostName}-doti3config";
}
