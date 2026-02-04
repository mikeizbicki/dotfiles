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
function llm_blue() {(
    # this function wraps the output of llm in blue text
    # and it copies the output to the clipboard
    printf "\033[94m"
    local tempfile=$(mktemp)
    trap "rm -f '$tempfile'; printf '\033[0m'" EXIT
    command llm "$@" | tee "$tempfile"
    xsel --clipboard -i < "$tempfile"
    printf '\033[0m'
) # the function is enclosed in a subshell to trigger the TRAP for cleanup
}
alias groq='llm_blue -s "keep your response short, between 5-20 lines" -m groq/llama-3.3-70b-versatile'
#alias claude='llm_blue -s "keep your response short, between 5-20 lines" -m anthropic/claude-3-7-sonnet-20250219'

function claude() {(
    #model=anthropic/claude-sonnet-4-0
    #cost_input=3
    #cost_output=15

    model=anthropic/claude-opus-4-5-20251101
    cost_input=5
    cost_output=25

    system_prompt="Keep your response short, between 1-20 lines. Focus on a high signal to noise ratio. If the question is about a computer, respond for the following system: $(uname -a)."

    # Capture stderr while preserving stdout
    local stderr_file=$(mktemp)
    trap "rm -f '$stderr_file'" EXIT
    llm_blue -s "$system_prompt" -m "$model" "$@" -u 2>"$stderr_file"
    stderr_content=$(cat "$stderr_file")
    local exit_code=$?
    latest_cid=$(llm logs list -n 1 --json | jq -r '.[] | .conversation_id' 2>/dev/null)
    # NOTE:
    # There is a minor race condition here.
    # The llm logs command above extracts the cid of the most recent conversation, which is almost certainly the conversation from the llm_blue call above.
    # But it is possible that a concurrently running llm process terminates after the llm_blue and before llm logs.
    # This shouldn't be a major concern in practice because this function is designed to be run interactively by a user and not inside a script.

    #echo "$stderr_content" | xclip -selection clipboard

    # Try to extract token usage from stderr
    if [[ $stderr_content =~ Token\ usage:\ ([0-9,]+)\ input,\ ([0-9,]+)\ output ]]; then
        input_tokens="${BASH_REMATCH[1]//,/}"
        output_tokens="${BASH_REMATCH[2]//,/}"
        cost_input=$(echo "scale=10; $cost_input * $input_tokens / 1000000" | bc -l)
        cost_output=$(echo "scale=10; $cost_output * $output_tokens / 1000000" | bc -l)
        cost_total=$(echo "scale=10; $cost_input + $cost_output" | bc -l)
        printf "cost: $%.4f (input: $%0.4f, output: $%0.4f) --cid=$latest_cid\n" "$cost_total" "$cost_input" "$cost_output" >&2
    else
        # If pattern doesn't match, display the stderr content
        if [[ -n $stderr_content ]]; then
            echo "$stderr_content" >&2
        fi
        input_tokens=""
        output_tokens=""
    fi

    return $exit_code
) # the function is enclosed in a subshell to trigger the TRAP for cleanup
}


function wtf() {
    # first we use kitty to get the content of our terminal session;
    screen_text=$(kitty @ get-text --extent=screen --self | head -n -1)
    screen_text=$(echo "$screen_text" | head -n -1)
    # NOTE: 
    # The kitty @ get-text command outputs the current contents of the screen to stdout. This content will contain the wtf command that has been typed into the terminal, which we remove with the 'head -n -1' command. This helps the LLM not get confused.

    # Many programs print files and line numbers in their error messages.
    # The following code scans the screen_text variable for any file names + line number combos,
    # and extracts portions of those files to add to the context.
    files_lines=$(echo "$screen_text" | grep "File \"" | sed 's/.*File "\([^"]*\)", line \([0-9]*\).*/\1:\2/')
    files_context=$(while IFS=: read -r filepath linenum; do
        #echo $filepath $linenum
        # Get relative path from current directory
        relpath=$(realpath --relative-to="$(pwd)" "$filepath" 2>/dev/null)

        # Check if file is within current directory (doesn't start with ../)
        if [[ "$relpath" != ../* ]] && [[ -f "$filepath" ]]; then
            echo "=== $filepath (around line $linenum) ==="
            # Show 10 lines before and after the error line, with line numbers
            startline=$((linenum-10 > 1 ? linenum-10 : 1))
            cat -n "$filepath" | sed -n "$startline,$((linenum+10))p"
            echo
        fi
    done <<< "$files_lines")

    prompt=$(cat <<EOF
The following is a copy/paste of my current terminal session.
There is an error message (or something else "weird"), and your job is to explain it.
Do not restate the error, only explain the cause and how to fix it.

\`\`\`
$screen_text
\`\`\`

Here is some potentially helpful system information.
All of the commands below were run after the terminal session above.

\`\`\`
$ uname -a
$(uname -a)
$ id
$(id)
$ pwd
$(pwd)
$ ls | head -n 50
$(ls | head -n 50)
$ ps | head -n 20
$(ps | head -n 20)
$ env | grep SSH
$(env | grep SSH)
\`\`\`

NOTE:
The head commands above may truncate the output of the informative commands. If that happens, and you need more output to understand the problem, say so.

$files_context

NOTE:
You must ensure the correctness of your response.
It is better to say that you do not understand the cause of an error (or that you need more information) than it is to state an incorrect cause of the error.
NEVER STATE FALSE INFORMATION.
EOF
)
    system='You are not having a conversation. Prioritize clarity and a high signal to noise ratio. Use technical terms as appropriate that a senior programmer would understand. Use markdown code blocks to format any code. The response should be as short as possible. Simple responses (e.g. describing a syntax error) can be 1 sentence. More complicated explanations can be 5-20 sentences.'
    model=groq/llama-3.3-70b-versatile
    #model=anthropic/claude-sonnet-4-0
    llm_blue -s "$system" --no-log -m "$model" "$prompt"
    #echo "$screen_text"
}

#function python3() { python3 "$@" || wtf; };
#alias python=python3
