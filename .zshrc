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

# Startup
fastfetch

# Aliases
alias ls='eza --icons'
alias ll='eza -al --icons'
alias ltr='eza -a --tree --level=1 --icons'
alias c='clear'
alias cat='bat'
alias activate='source ~/.venv/bin/activate'
alias vimage='kitty +kitten icat'
alias cpu='auto-cpufreq --stats'
alias zed='zeditor'

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
