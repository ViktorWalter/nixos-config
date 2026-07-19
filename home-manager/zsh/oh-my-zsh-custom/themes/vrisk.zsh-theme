#vrisk zsh theme
local ret_status_prompt="%(?:%{$fg_bold[green]%}>:%{$fg_bold[red]%}>>%{$reset_color%})"
local ret_status_separator="%(?:%{$fg_bold[green]%}${(r:15::=:::)}:%{$fg_bold[red]%}${(r:15::=:::)})%{$reset_color%}"
local infobar="%{$fg_bold[blue]%}%3~%{$reset_color%} %{$fg[white]%}[%n@%m]%{$reset_color%}%{$fg[white]%}[%T]%{$reset_color%}"
# local top_line="%$COLUMNS<$infobar<$ret_status_separator%<<"

PROMPT=$'$infobar
$ret_status_prompt'

RPROMPT=$'$ret_status_separator'

# RPROMPT='${ret_status_separator}%{$reset_color%}'

GIT_CB="git::"
ZSH_THEME_SCM_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_PREFIX=$ZSH_THEME_SCM_PROMPT_PREFIX$GIT_CB
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

