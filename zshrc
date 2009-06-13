###############################################################################
## Set PATH type things
###############################################################################


export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin   # standard system locations
export PATH=$PATH:/usr/local/bin                  # misc other local stuff
export PATH=/usr/local/mysql/bin:$PATH            # mysql
export PATH=~/bin:$PATH                           # pull in my own bin before a lot of those others

# Catch any desired overrides
export PATH=$PATHOVERRIDES:$PATH

###############################################################################
## Set Aliases and Functions
###############################################################################
function ls    { command ls -AFGh "$@"; } 
	# 'command ls' to prevent loop; -A for .file, -F for dir/ link@, 
	# -G is for color
function l     { ls -l "$@"; } # -l to list in long format... 
function ll    { l "$@" | less ; } # pipe into 'less'

# Get pretty tree output by default
function tree { command tree -A "$@"; }

# less sucks for me for some reason
function less { command less -X "$@"; }

alias ..='cd ..;l'
alias cd..='cd ..'
alias rehash='. ~/.zshrc;' # source ~/.bashrc after I edit it 


alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'       # no spelling correction on cp
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir

# List only directories and symbolic
# links that point to directories
alias lsd='ls -ld *(-/DN)'

## Git Specific
alias gst='git status'
alias gl='git log'
alias gd='git diff | mate'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gb='git branch'
alias gba='git branch -a'
alias gm='git checkout master'
alias gsr='git svn rebase'
alias gr='git rebase'
alias grm='git rebase master'
alias gco='git checkout'

###############################################################################
## Misc
###############################################################################

# Needed to keep TextMate bundle svn updating happy
export LC_CTYPE=en_US.UTF-8

# Set color codes for ls -G
export LSCOLORS=fxfxcxdxbxegedabagacad 
	# default except for the first character (f) - magenta for directories
	# the standard blue blended into the black of my terminal too much

# I am TextMate's bitch, after that... nano
if which mate > /dev/null; then
    export EDITOR="mate -w"
else
    export EDITOR="nano"
fi

# less is more. depending on my mood.
#   note: The -X keeps the output on screen when less quits. handy.
export PAGER="less -X"
export MANPAGER="less -X"

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath

# Set term type
export TERM=xterm-color

###############################################################################
## History settings. See http://zsh.sunsite.dk/Guide/zshguide02.html
###############################################################################
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.history

setopt append_history
setopt inc_append_history
setopt extended_history
       
setopt hist_ignore_dups
setopt hist_expire_dups_first

# Disabled this because it's just fucking annoying:
#setopt share_history 

###############################################################################
### `Go faster' options for power users.
### See http://zsh.sunsite.dk/Guide/zshguide02.html
###############################################################################

setopt no_beep
setopt auto_cd

# Make cd push the old directory onto the directory stack.
setopt auto_pushd
setopt pushd_ignore_dups
# Disabled this because it's just fucking annoying:
#setopt correct

###############################################################################
## ZLE settings. See zshle(1)
###############################################################################
# use emacs-style
bindkey -e

###############################################################################
## Completion
###############################################################################
# Setup new style completion system. To see examples of the old style (compctl
# based) programmable completion, check Misc/compctl-examples in the zsh
# distribution.
autoload -U compinit
compinit


###############################################################################
## Set the prompt
## (stolen from: http://www.aperiodic.net/phil/prompt/)
###############################################################################
function precmd {

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))


    ###
    # Truncate the path if it's too long.
    
    PR_FILLBAR=""
    PR_PWDLEN=""
    
    local promptsize=${#${(%):---(%n@%m:%l)---()--}}
    local pwdsize=${#${(%):-%~}}
    
    if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
	    ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
	    PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
    fi

    ###
    # Get Git info.
    PR_GIT_BRANCH=$( git symbolic-ref HEAD 2>/dev/null| cut -d/ -f3,4,5,6 )
    
}


setopt extended_glob
preexec () {
}


setprompt () {
    ###
    # Need this so the prompt will work.

    setopt prompt_subst


    ###
    # See if we can use colors.

    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
	    colors
    fi
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
        eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
        eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
        (( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"


    ###
    # See if we can use extended characters to look nicer.
    
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}

    
    ###
    # Decide if we need to set titlebar text.
    
    case $TERM in
	xterm*)
	    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
	    ;;
	*)
	    PR_TITLEBAR=''
	    ;;
    esac


    ###
    # set the git branch

    PR_GIT='$PR_RED${PR_GIT_BRANCH[(w)5,(w)6]/\% /%%}$PR_LIGHT_BLUE:'

    ###
    # Finally, the prompt.

    PROMPT='$PR_SET_CHARSET${(e)PR_TITLEBAR}\
$PR_CYAN$PR_SHIFT_IN$PR_ULCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_GREEN%(!.%SROOT%s.%n)$PR_GREEN@%m:%l\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_HBAR${(e)PR_FILLBAR}$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_MAGENTA%$PR_PWDLEN<...<%~%<<\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_URCORNER$PR_SHIFT_OUT\

$PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
%(?..$PR_LIGHT_RED%?$PR_BLUE:)\
${(e)PR_GIT}$PR_YELLOW%D{%H:%M}\
$PR_LIGHT_BLUE:%(!.$PR_RED.$PR_WHITE)%#$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_NO_COLOUR '

    RPROMPT=' $PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_BLUE$PR_HBAR$PR_SHIFT_OUT\
($PR_YELLOW%D{%a,%b%d}$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

    PS2='$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_BLUE$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
$PR_LIGHT_GREEN%_$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
}

setprompt

