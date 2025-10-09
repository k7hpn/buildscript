#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v]

Pre-build release preparation script

Available options:

-h, --help      Print this help and exit
--no-color	Do not use color codes in script output
-p		Perform publish steps
-v, --verbose   Print script debug info
EOF
    exit
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # script cleanup here
}

setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg=$1
    local code=${2-1} # default exit status 1
    msg "$msg"
    exit "$code"
}

parse_params() {
    # default values of variables set from params
    publish=0
    
    while :; do
        case "${1-}" in
            -h | --help) usage ;;
            -v | --verbose) set -x ;;
            --no-color) NO_COLOR=1 ;;
            -p | --publish) publish=1 ;;
            -?*) die "Unknown option: $1" ;;
            *) break ;;
        esac
        shift
    done
    
    return 0
}

parse_params "$@"
setup_colors

# script logic here

readonly PUB_STARTAT=$SECONDS

if [[ publish -eq 1 ]]; then
    msg "${BLUE}===${NOFORMAT} Performing publish release prep"
    sleep 2
    msg "${PURPLE}===${NOFORMAT} Release prep successful in $((SECONDS - PUB_STARTAT)) seconds."
else
    msg "${RED}===${NOFORMAT} Missing -p flag, not running release prep"
fi

