# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

$LOG_FILE = ""

LOG(){
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') $1 $2" | tee -a "$LOG_FILE"
}

SET_LOG_FILE(){
    LOG_FILE="$1"
}

OK(){
    LOG "$OK" "$1"
}

INFO(){
    LOG "${INFO}" "$1"
}

WARN(){
    LOG "${WARN}" "$1"
}

ACTION(){
    LOG "${CAT}" "$1"
}

NOTE(){
    LOG "${NOTE}" "$1"
}

ERROR(){
    LOG "${ERROR}" "$1"
}
