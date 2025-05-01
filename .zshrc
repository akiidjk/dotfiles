
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="xiong-chiamiov-plus"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
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
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

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

alias docker-start='sudo systemctl start docker.service'
alias docker-stop='sudo systemctl stop docker.service'
alias docker-status='sudo systemctl status docker.service'

alias start-vpn='sudo openvpn --config ~/WorkSpace/Utils/protonvpn/protonvpn.tcp.ovpn --auth-user-pass ~/WorkSpace/Utils/protonvpn/.vpn_creds'
alias stop-vpn='sudo killall openvpn'
alias upgradesys='~/WorkSpace/Utils/scripts/upgrade_sys.sh'
alias cleansys='~/WorkSpace/Utils/scripts/clean.sh'

alias webtemplate='python3 ~/WorkSpace/Utils/scripts/webtemplate/main.py'
alias webup='python3 -m http.server 6969'
alias pymain='echo -e "\n\ndef main():\n    pass\n\nif __name__ == \"__main__\":\n    main()" > main.py'

alias mp4ToMov='~/WorkSpace/Utils/scripts/mp4ToMov.sh'
alias movToMp4='~/WorkSpace/Utils/scripts/movToMp4.sh'
alias vmw11='quickemu --vm ~/WorkSpace/VM/windows-11.conf --display spice'
alias jwt_tool='~/WorkSpace/Tools/jwt_tool/env/bin/python3 ~/WorkSpace/Tools/jwt_tool/jwt_tool.py'
alias connectmain='ssh -i ~/WorkSpace/Utils/sshkey-vm/main/ssh-key-2025-03-01.key ubuntu@158.180.230.169'
alias togglemirror='./WorkSpace/Utils/scripts/toggle_mirror.sh'
alias mdtopdf='docker run -it --rm -v "`pwd`":/workdir plass/mdtopdf mdtopdf'
alias start-aperisolve='~/WorkSpace/Tools/AperiSolve/start.sh'
alias stop-aperisolve='~/WorkSpace/Tools/AperiSolve/stop.sh'

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# FZF
export FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --preview 'bat --color=always --style=header,grid --line-range :300 {}'"

# Path
export PATH=$PATH:/home/akiidjk/.cargo/bin
export PATH=$PATH:/home/akiidjk/.spicetify

# Pyenv
eval "$(pyenv init -)"
export WORKON_HOME=$HOME/.virtualenvs
source /bin/virtualenvwrapper.sh
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"

export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:/home/akiidjk/.modular/bin"
export XDG_CONFIG_HOME="$HOME/.config"

. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

# bun completions
[ -s "/home/akiidjk/.bun/_bun" ] && source "/home/akiidjk/.bun/_bun"

# bun
export BUN_INSTALL="/"
export PATH="$BUN_INSTALL/bin:$PATH"

TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'

[ -f "/home/akiidjk/.ghcup/env" ] && . "/home/akiidjk/.ghcup/env" # ghcup-env
