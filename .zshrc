export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="xiong-chiamiov-plus"

plugins=(
  aliases
  cp
  zsh-autosuggestions
  zsh-syntax-highlighting
  git
  docker
  last-working-dir
  history-substring-search
  history
  pylint
  pip
  golang
  ssh
  encode64
  extract
)

source $ZSH/oh-my-zsh.sh

# User configuration

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Starship
eval "$(starship init zsh)"
# Zoxide
eval "$(zoxide init zsh)"
# Startup
fastfetch

# Aliases
alias cd='z'
alias f='nvim "$(fzf --multi)"'
alias ls='eza --icons'
alias ll='eza -al --icons'
alias ltr='eza -a --tree --level=1 --icons'
alias c='clear'
alias cat='bat'
alias activate='source ~/.venv/bin/activate'
alias vimage='kitty +kitten icat'
alias cpu='auto-cpufreq --stats'
alias zed='zeditor'
alias ssh='kitty +kitten ssh'
alias k='kubectl'

alias docker-start='sudo systemctl start docker.service'
alias docker-stop='sudo systemctl stop docker.service'
alias docker-status='sudo systemctl status docker.service'

alias start-vpn='sudo openvpn --config <path_to_config> --auth-user-pass <path_to_creds>'
alias stop-vpn='sudo killall openvpn'
alias upgradesys='~/scripts/upgrade_sys.sh'
alias cleansys='~/scripts/clean.sh'

alias webtemplate='python3 ~/scripts/webtemplate/main.py'
alias webup='python3 -m http.server 6969'
alias pymain='echo -e "\n\ndef main():\n    pass\n\nif __name__ == \"__main__\":\n    main()" > main.py'
alias togglemirror='~/scripts/toggle_mirror.sh'

# Alias for network forwarding wifi to ethernet
# nmcli connection add type ethernet ifname enp3s0 con-name eth-shared ipv4.method shared ipv6.method ignore
# nmcli connection up eth-shared
# sudo sysctl -w net.ipv4.ip_forward=1
alias up_forward='nmcli connection up eth-shared'
alias down_forward='nmcli connection down eth-shared'

# Suffix alias
alias -s json=jless
alias -s md=mdcat
alias -s go='$EDITOR'
alias -s zig='$EDITOR'
alias -s txt=bat
alias -s log=bat
alias -s py='$EDITOR'
alias -s js='$EDITOR'
alias -s ts='$EDITOR'

# Global alias
alias -g NE='2>/dev/null' # Redirect stderr to /dev/null
alias -g NO='>/dev/null' # Redirect stdout to /dev/null
alias -g NUL='>/dev/null 2>&1' # Redirect both stdout and stderr to /dev/null
alias -g J='| jq' # Pipe to jq
alias -g C='| wl-copy' # Copy output to clipboard

# Expands history expressions like !! or !$ when you press space/tab
bindkey ' ' magic-space

chpwd() {
    ls
}


# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# FZF
export FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'"

# Path
export XDG_CONFIG_HOME="$HOME/.config"

# MacShell Dynamic Island: a command that ran 15 s or more reports back in the notch when it ends
# (interactive programs are skipped: quitting vim is not news)
autoload -Uz add-zsh-hook
_island_t0=0
_island_preexec() { _island_t0=$SECONDS; _island_cmd=$1 }
_island_precmd() {
    local st=$? d=$(( SECONDS - _island_t0 )) c=${${_island_cmd%% *}##*/}
    (( _island_t0 > 0 && d >= 15 )) || { _island_t0=0; return }
    _island_t0=0
    case $c in vim|nvim|vi|nano|ssh|less|more|man|htop|btop|top|yazi|lazygit|tmux|zellij|fzf|watch|tail|journalctl) return ;; esac
    local t; (( st == 0 )) && t="✓ $c" || t="✗ $c (exit $st)"
    qs -c MacShell ipc call island notify "$t" "$(( d / 60 ))m $(( d % 60 ))s" "" &>/dev/null &!
}
add-zsh-hook preexec _island_preexec
add-zsh-hook precmd _island_precmd
