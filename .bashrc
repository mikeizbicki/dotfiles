export LANG='en_US.UTF-8'

#######################################
# colors taken from: https://wiki.archlinux.org/index.php/Color_Bash_Prompt

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White


#######################################

export PYTHONPATH=.
export EDITOR=vim

# fix lambda server bug where numpy libraries crash on load
export OMP_NUM_THREADS=4

# local docker setup
export PATH=~/.local/bin:~/bin:$PATH
export DOCKER_HOST=unix:///run/user/$UID/docker.sock

# make bash history size unlimited and shared
HISTSIZE=
HISTFILESIZE=
PROMPT_COMMAND='history -a'
shopt -s histappend

# use fzf for ctrl-r;
# the settings below are designed to ensure that multiline commands (long heredocs)
# are easily searchable
shopt -s cmdhist lithist
export HISTTIMEFORMAT='%F %T '
source /usr/share/doc/fzf/examples/key-bindings.bash

# set public environment variables
export PATH=~/.local/bin:~/.cabal/bin:~/bin:$PATH
export DOCKER_HOST=unix:///run/user/$UID/docker.sock
export C_INCLUDE_PATH=~/.local/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=~/.local/include:$CPLUS_INCLUDE_PATH

# store git credentials for 1 year in ram after they are first entered
git config --global credential.helper 'cache --timeout=31536000'

# update prompt to display repo info
. ~/.git-prompt.sh
if [ "$(hostname)" = "userland" ]; then
    hoststr=""
else
    hoststr="\[$Green\]\h\[$Red\]:"
fi
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM='auto'
export PS1="$hoststr\[$Green\]\w\[$Purple\]\$(__git_ps1 ) \[$Green\]$\[$Color_Off\] "

# don't use gtk passwords from the commandline
unset SSH_ASKPASS

# colorize ls
eval "`dircolors -b ~/.dircolors`"
alias ls='ls --color=auto'

# .env can store private environment variables like API keys;
# load them if they exist
if [ -s ~/.env ]; then
    # set -a causes all variables to be environment variables
    set -a
    source ~/.env
    set +a
fi

# load pyenv if it exists
if [ -e ~/.pyenv/bin/pyenv ]; then
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
fi

# load a default python venv if it exists
if [ -e ~/.venv/bin/activate ]; then
    source ~/.venv/bin/activate
fi

# load the ai_scripts
source ~/.ai_scripts/shell/geni.sh

####################
# useful aliases
####################

function koine() {
    opus -s "You are generating an anki flashcard for the specified koine greek word. The output should have the following sections: etymology, related words (Greek), and related words (English). The etymology should be useful for language learners (focus on greek derivations, not PIE). The related words (English) section should only focus on eytmological relations, the related word (Greek) should focus on etymologically related words (but it is also okay to include up to 2 words that are easy to confuse because they have similar meaning or similar sounds). Each section should have the title in <b> tag. The related words should be in a <ol>, with each word a <li> (inside the li tag, state the related word followed by - followed by explanation. Wrap each section in a div tag. If any of the above lists do not have meaningful entries, leave the entire list out (do not say that there are no entries)." "$1"
}

alias kitty='kitty -1 --detach --directory "$PWD"'
alias icat="\kitty +kitten icat"
alias scan="scanimage -d 'brother4:net1;dev0' --format=png -o scan.png"

####################
# debug utilities
####################

# show any un-committed changes to dotfiles;
# this helps ensure that whatever settings changes get committed/uploaded
# and not forgotten about
git diff --cached --quiet && git diff --quiet || git diff HEAD --stat

# the purpose of the functions below is to help prevent data loss;
# they can be run to ensure that all info in a repo is committed and pushed to github
is_repo_save() {
  local d
  for d in "$@"; do
    [[ -d $d/.git ]] || continue
    ( cd "$d" || exit
      local problems=()
      [[ -n $(git status --porcelain) ]] && problems+=("DIRTY")
      if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
        a=$(git rev-list --count '@{u}..HEAD')
        [[ ${a:-0} -gt 0 ]] && problems+=("UNPUSHED ($a)")
      else
        problems+=("NO-UPSTREAM")
      fi
      [[ ${#problems[@]} -gt 0 ]] && echo "$d: ${problems[*]}"
    )
  done
}
check_backup() {
    is_repo_saved ~/proj/*
}
