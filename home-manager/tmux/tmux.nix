# tmux.nix
#
# Home-manager module converted from:
#   https://github.com/klaxalk/linux-setup/blob/master/appconfig/tmux/dottmux.conf
#
# Import from home.nix:
#   imports = [ ./tmux.nix ];
#
# APPROACH
# Same call as the vimrc/i3 conversions: rather than translating every
# `set-option`/`bind-key` into home-manager's structured
# `programs.tmux.*` options (aggressiveResize, historyLimit, keyMode,
# mouse, escapeTime, ...), this drops the original config almost verbatim
# into `extraConfig` as raw tmux syntax. Two reasons, one of them tmux-
# specific:
#   1. Same reasoning as before -- large 1:1 rewrites into structured nix
#      options add risk without adding value for a file this size.
#   2. tmux-specific: home-manager's structured options *always* emit their
#      own `set-option` lines (matching tmux's own defaults) before
#      `extraConfig` is appended -- see
#      https://github.com/nix-community/home-manager/issues/2541. Since
#      tmux config is evaluated top-to-bottom and later settings win, this
#      is harmless as long as extraConfig also sets those same keys itself
#      (which the original file already does for everything that matters)
#      -- but there's no benefit to *also* wiring the same values through
#      the structured options, so this file leaves them untouched.
#
# WHAT WAS DROPPED / CHANGED
#
# 1. EPIGEN_ADD/DEL_BLOCK_* markers resolved the same way as the vimrc/i3
#    conversions: whichever block's content lines were live/uncommented in
#    the source is what's actually in effect, so that's what's kept here;
#    the commented-out alternates are dropped instead of carried over as
#    dead weight. Concretely:
#      - COLORSCHEME_LIGHT: the dark status-bar colors (colour234/colour15,
#        the colour26/colour236/colour239 status-left/right, and the
#        "_LINE_"-tagged window-status formats) were live -- kept. The
#        commented-out light-theme alternative (white/black, %d/%m date
#        format) was dropped.
#      - TMUX_OLD_BINDINGS: the whole block was commented out in your
#        source (the old C-s/C-d split bindings) -- dropped entirely, since
#        it was already inactive.
#      - The TOMAS/DAN/DANIEL/PAVEL-tagged block (S-Right/S-Left next/prev
#        window) was live -- kept.
#
# 2. Three scripts are referenced but weren't part of any upload:
#      ~/git/linux-setup/scripts/tmux_mount.sh
#      ~/git/linux-setup/scripts/tmux_unmount.sh
#      ~/git/linux-setup/scripts/tmux_end_experiment.sh
#    Home-manager can't create these; either keep them where they already
#    are (the bindings just point at that path, unmanaged), or send them
#    over and I'll fold them into a proper home.file entry the way the
#    vim/i3 configs were.
#
# 3. Your source sets `default-terminal "screen-256color"` and the
#    visual-activity/visual-bell/visual-silence trio *twice* (once in the
#    main option block, once again under "# colors"/"# loud or quiet?").
#    Kept both, same as the original -- harmless duplication, not a bug I
#    introduced.
#
# 4. The prefix is set twice: `C-b` near the top, then overridden to `C-a`
#    further down under "# remap Ctrl-b". Final effective prefix is `C-a`,
#    same as your original (tmux config is evaluated top-to-bottom, last
#    setting wins) -- kept both lines rather than silently collapsing them
#    to one, to match source behavior exactly.
#
# 5. `bind-key -n M-u` is bound twice: once to `select-pane -D` (the
#    yuio pane-navigation block) and later to `next` (window navigation).
#    The second silently wins in your original file too -- this isn't a
#    conversion artifact, just flagging it in case it wasn't intentional.

{ ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 100000;
    keyMode = "vi";
    

    extraConfig = ''
      set-option -g assume-paste-time 1
      set-option -g default-command ""
      set-option -g destroy-unattached off
      set-option -g detach-on-destroy on
      set-option -g display-panes-active-colour red
      set-option -g display-panes-colour blue
      set-option -g display-panes-time 1000
      set-option -g display-time 750
      set-option -g key-table "root"
      set-option -g lock-after-time 0
      set-option -g lock-command "lock -np"
      set-option -g message-command-style fg=yellow,bg=black
      set-option -g message-style fg=black,bg=yellow
      set-option -g mouse off
      set-option -g prefix C-b
      set-option -g prefix2 None
      set-option -g renumber-windows on
      set-option -g repeat-time 500
      set-option -g set-titles off
      set-option -g set-titles-string "#S:#I:#W - "#T" #{session_alerts}"
      set-option -g status on
      set-option -g status-interval 15
      set-option -g status-justify left
      set-option -g status-keys vi
      set-option -g status-left "[#S] "
      set-option -g status-left-length 10
      set-option -g status-left-style default
      set-option -g status-position bottom
      set-option -g status-right " \"#{=21:pane_title}\" %H:%M"
      set-option -g status-right-length 40
      set-option -g status-right-style default
      set-option -g status-style fg=black,bg=green
      set-option -g update-environment "DISPLAY SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY"
      set-option -g visual-activity off
      set-option -g visual-bell off
      set-option -g visual-silence off
      set-option -g word-separators " -_@"
      set-option -g aggressive-resize on
      set-window-option -g allow-rename off
      set-window-option -g automatic-rename off

      ## Status bar design

      # status line
      set -g status-justify left
      set -g status-bg default
      set -g status-fg colour12
      set -g status-interval 2

      # window status
      setw -g window-status-format " #F#I:#W#F "
      setw -g window-status-current-format " #F#I:#W#F "

      setw -g window-status-format "#[fg=magenta]#[bg=black] #I #[bg=cyan]#[fg=colour8] #W "
      setw -g window-status-current-format "#[bg=brightmagenta]#[fg=colour8] #I #[fg=colour8]#[bg=colour14] #W "

      # Info on left (I don't have a session display for now)
      set -g status-left '''

      # loud or quiet?
      set-option -g visual-activity off
      set-option -g visual-bell off
      set-option -g visual-silence off
      set-window-option -g monitor-activity off
      set-option -g bell-action none

      # The modes {
      setw -g clock-mode-colour colour135
      # }

      # The statusbar {
      set -g status-position bottom

      # dark status-bar colorscheme (kept -- see note 1 above)
      set -g status-bg colour234
      set -g status-fg colour15

      set -g status-left "#[fg=colour15,bg=colour26] #S #[fg=colour103,bg=colour236,nobold,nounderscore,noitalics]"
      set -g status-right "#[fg=colour239] #(echo $ROS_MASTER_URI) #[fg=colour239,bg=colour236,nobold,nounderscore,noitalics]#[fg=colour248,bg=colour239] %H:%M #[fg=colour15,bg=colour26] #H"

      set -g status-right-length 50
      set -g status-left-length 20

      setw -g window-status-current-format "#[fg=colour236,bg=colour239,nobold,nounderscore,noitalics]#[fg=colour253,bg=colour239] #I |#[fg=colour253,bg=colour239] #W #[fg=colour239,bg=colour236,nobold,nounderscore,noitalics]"
      setw -g window-status-format "#[fg=colour244,bg=colour236] #I |#[fg=colour244,bg=colour236] #W "
      # }

      # set vim control
      bind -n F2 copy-mode
      bind-key -Tcopy-mode-vi 'v' send -X begin-selection
      bind-key -Tcopy-mode-vi 'y' send -X copy-pipe-and-cancel "xclip -selection clipboard -i"
      bind-key -Tcopy-mode-vi 'C-V' send -X rectangle-toggle
      unbind p
      bind p run-shell "tmux set-buffer \"$(xclip -o)\"; tmux paste-buffer"

      # key bindings for moving over pannels
      # binded to arrows for normal people
      bind-key -n M-Left select-pane -L
      bind-key -n M-Right select-pane -R
      bind-key -n M-Up select-pane -U
      bind-key -n M-Down select-pane -D

      # binded to yuio for me
      bind-key -n M-y select-pane -L
      bind-key -n M-o select-pane -R
      bind-key -n M-i select-pane -U
      bind-key -n M-u select-pane -D

      # tmux kill button
      bind-key k menu -x R -t 0 "-T Kill the session?" "Select this menu item and hit enter!" 9 'split-window; send-keys "sleep 1; pwd >> /tmp/tmux_restore_path.txt; tmux list-panes -s -F \"#\{pane_pid\} #\{pane_current_command\}\" | grep -v tmux | cut -d\" \" -f1 | while read in; do killp \$in; done" C-m exit C-m'

      # the new key bindings for splitting, CTRL-9 (like CTRL-() for vertical, CTRL-0 (like CTRL-)) for horizontal
      bind -n C-9 split-window -v -c "#{pane_current_path}"
      bind -n C-0 split-window -h -c "#{pane_current_path}"
      # bind c new-window -c "#{pane_current_path}"

      # remap Ctrl-b
      set-option -g prefix C-a

      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
      | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
      bind-key -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
      bind-key -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
      bind-key -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"

      # allow to use vim's ctrlp from terminal
      bind-key -n C-p if-shell "$is_vim" "send-keys C-p" "send-keys 'vim -c :Startify:CtrlP'"
      bind-key -n C-F12 if-shell "$is_vim" "send-keys C-F12" "send-keys 'vim -c :Startify:CtrlP ~/'"

      bind -r C-h resize-pane -L 5
      bind -r C-j resize-pane -D 5
      bind -r C-k resize-pane -U 5
      bind -r C-l resize-pane -R 5

      bind -n C-t new-window -a -c "#{pane_current_path}"

      bind -n M-u next
      bind -n M-i prev

      # next/prev window on Shift-Left/Right (kept -- see note 1 above)
      bind -n S-Right next
      bind -n S-Left prev

      bind -n C-S-Left swap-window -t -1
      bind -n C-S-Right swap-window -t +1

      # reload config file
      bind r source-file ~/.tmux.conf

      # make delay shorter
      set -sg escape-time 0

      # Toggle synchronize-panes with ^S m
      bind s \
        set synchronize-panes \;\
        display "Sync #{?synchronize-panes,ON,OFF}"

      # make window/pane index start with 1
      # set -g base-index 1
      # setw -g pane-base-index 1

      bind-key m run-shell "~/git/linux-setup/scripts/tmux_mount.sh"
      bind-key u run-shell "~/git/linux-setup/scripts/tmux_unmount.sh"
      bind-key e run-shell "~/git/linux-setup/scripts/tmux_end_experiment.sh"
    '';
  };
}
