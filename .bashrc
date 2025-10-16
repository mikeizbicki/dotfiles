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

# make bash history size unlimited and shared
HISTSIZE=
HISTFILESIZE=
PROMPT_COMMAND='history -a'
shopt -s histappend

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
function dirty()
{
	if [[ $(git status --porcelain) ]]; then
		echo '- dirty'
	fi
}
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
if [ -e ~/.env ]; then
    export $(cat ~/.env)
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

# This function is useful for preprocesssing LLM prompts.
# It outputs each line of stdin.
# For each line that begins with a shell prompt '$',
# it additionally outputs the command's stdin/stdout to stdout.
# This results in the output of the commands also being included in the prompt.
# For example:
#
#   $ expand_shell_markdown <<'EOF'
#   Help me interpret the following command:
#   $ uname -a
#   What OS am I using?
#   EOF
#
# will generate output like the following:
#
#   Help me interpret the following command:
#   ```bash
#   $ uname -a
#   Linux laptop1 5.10.0-33-amd64 #1 SMP Debian 5.10.226-1 (2024-10-03) x86_64 GNU/Linux
#   ```
#   What OS am I using?
#
# Using the later output, an LLM can actually answer the posed question.
expand_shell_markdown() {
    local in_codeblock=false

    while IFS= read -r line; do
        if [[ $line == \$* ]]; then
            if [[ $in_codeblock == false ]]; then
                echo '```bash'
                in_codeblock=true
            fi
            echo "$line"
            eval "${line#\$}" 2>&1
        else
            if [[ $in_codeblock == true ]]; then
                echo '```'
                in_codeblock=false
            fi
            echo "$line"
        fi
    done

    # Close any open code block at the end
    if [[ $in_codeblock == true ]]; then
        echo '```'
    fi
}

# useful llm aliases
function llm_blue() {
    printf "\033[94m"
    expand_shell_markdown | command llm "$@"
    printf "\033[0m"
}
alias groq='llm_blue -s "keep your response short, between 5-20 lines" -m groq/llama-3.3-70b-versatile'
#alias claude='llm_blue -s "keep your response short, between 5-20 lines" -m anthropic/claude-3-7-sonnet-20250219'
alias claude='llm_blue -s "keep your response short, between 5-20 lines" -m anthropic/claude-sonnet-4-0'

####################

function koine() {
    claude "Take the following Koine Greek word and: define it; break it into root parts; list other common words that use the same roots (focus on the root and not prefix/suffixes, and only provide the list if the words exist and are common; do not provide any transliterations into english; list any modern english words derived from the specified word. If any of the above lists do not have meaningful entries, leave the entire list out (do not say that there are no entries). $1"
}
