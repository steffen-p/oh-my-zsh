dir=$(dirname $0)

export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto verbose name"
export GIT_PS1_DESCRIBE_STYLE="branch"

source $dir/git-prompt.sh
