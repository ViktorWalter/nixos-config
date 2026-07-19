{ hostName, config, pkgs, lib, ... }:

let
  here = toString ./.;
in
{
  programs.zsh = {
    enable = true;
    package = pkgs.athame-zsh;

    autosuggestion.enable = false;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases = {
      ll = "ls -la";
      sb = "source ~/.zshrc";
      ra = "ranger";
      vim = "runVim";
      vimdiff = "nvim -d";
      ".." = "cd ..";
      ":q" = "exit";
      neofetch = "hyfetch";
      update = "sudo nixos-rebuild switch";
    };

    oh-my-zsh = { # "ohMyZsh" without Home Manager
      enable = true;
      plugins = [ "git" "ros" "sudo" ];
      custom = "${here}/oh-my-zsh-custom"; # plain string path, not ./mytheme
      theme = "vrisk";
    };


    initContent = ''
      export TERMSESSION="yes"
      export EDITOR="$(which nvim) --cmd 'let g:user_mode=1'"
      export TMUX_BIN=`which tmux`
  
      unset zle_bracketed_paste
      unsetopt share_history
  
      killp () {
  
        if [ $# -eq 0 ]; then
          pes=$( cat ) 
        else
          pes=$1
        fi
  
        for child in $(ps -o pid,ppid -ax | \
          awk "{ if ( \$2 == $pes ) { print \$1 }}")
              do
                # echo "Killing child process $child because ppid = $pes"
                killp $child
              done
  
       kill -9 "$1" > /dev/null 2> /dev/null
      }
  
  
      runTmux() {
  
        SESSION_NAME="T$PPID"
  
        # try to find session with the correct session id (based on the zsh PID)
        EXISTING_SESSION=`$TMUX_BIN ls 2> /dev/null | grep "$SESSION_NAME" | wc -l`
  
        if [ "$EXISTING_SESSION" -gt "0" ]; then
  
          # if such session exists, attach to it
          $TMUX_BIN -2 attach-session -t "$SESSION_NAME"
  
        else
  
          # if such session does not exist, create it
          $TMUX_BIN new-session -s "$SESSION_NAME"
  
        fi
  
        # hook after exitting the session
        # when the session exists, find a file in /tmp with the name of the session
        # and extract a path from it. Then cd to it.
        FILENAME="/tmp/tmux_restore_path.txt"
        if [ -f $FILENAME ]; then
    
          MY_PATH=$(tail -n 1 $FILENAME)
    
          rm /tmp/tmux_restore_path.txt
    
          cd $MY_PATH
    
        fi
      }
  
      runVim() {
      
        VIM_CMD=$(echo "$EDITOR ''${@}")
      
        # if the tmux session does not exist, create new and run vim in it
        if [ -z $TMUX ]; then
      
          SESSION_NAME="T$PPID"
      
          # if there is a tmux session with the same name as the current bashpid
          num=`$TMUX_BIN ls 2> /dev/null | grep "$SESSION_NAME" | wc -l`
          if [ "$num" -gt "0" ]; then
      
            ID=`$TMUX_BIN new-window -t "$SESSION_NAME" -a -P`
            sleep 1.0
            $TMUX_BIN send-keys -t $ID "$VIM_CMD" C-m
            $TMUX_BIN -2 attach-session -t "$SESSION_NAME"
      
          else
      
            $TMUX_BIN new-session -s "$SESSION_NAME" -d "$VIM_CMD" \; attach
      
          fi
      
        else
      
          zsh -c "$VIM_CMD"
      
        fi
      }
  
      kzsh() {
        for i in `ps aux | grep "\-[z]sh" | awk '{print $2}'`; do   
          killp "$i"
        done
      }
  
      # run Tmux automatically in every normal terminal
      export RUN_TMUX=true
      # export RUN_TMUX=false
      
      # use Athame in every normal terminal
      export USE_ATHAME=true
  
      # if athame fails
      set -o vi
  
      # use the vi navigation keys in menu completion
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history
      alias vimr='vim --remote-silent'
  
  
      # path to the git root
      export GIT_PATH=''${HOME}/git
  
      export LESS='-R'
      export LESSOPEN='|~/.lessfilter %s'
  
  
      # is the shell running interactively
      case "$-" in
        *i*) INTERACTIVE_SHELL=1
      esac
  
      # load tmux automatically
      if [ ! -z "$INTERACTIVE_SHELL" ]; then # when loaded interactively, run tmux
        if [ "$RUN_TMUX" = "true" ]; then
          if command -v $TMUX_BIN>/dev/null; then
            [[ ! $TERM =~ screen ]] && [ -z $TMUX ] && runTmux
          fi
        fi
      fi
  
  
      source ''${HOME}/.my.zshrc # Important ! These are per-computer configs I can change from the home directory
    '';
  };

  # make the additionall zshrc editable from home
  home.file.".my.zshrc".source = 
    config.lib.file.mkOutOfStoreSymlink
    "${here}/${hostName}-dotzshrc";


  home.file.".athamerc".text = ''
    source /etc/athamerc
  '';

}
