#!/bin/bash
# lib/core.sh - Shared core functions for image-factory

# Default variable names
# VERBOSE=true/false

# This script should be sourced, not executed
(return 0 2>/dev/null) || \
{ echo "This script should be sourced! Terminating."; exit 1; }

# Shell safeguards
set -euo pipefail

# Color definitions for log clarity
readonly LOG_RED='\033[0;31m'
readonly LOG_GREEN='\033[0;32m'
readonly LOG_YELLOW='\033[1;33m'
readonly LOG_BRED='\033[1;91m'
readonly LOG_NC='\033[0m'

# Log date format definition
readonly LOG_DATE_CMD="date +'%Y-%m-%d %H:%M:%S'"

# Immediate script termination
abort() { echo -e "${LOG_BRED}Terminated.${LOG_NC}" >&2; exit 1; }

# Standard information message
msg() {
    echo -e "${LOG_GREEN}[$(eval ${LOG_DATE_CMD})] INFO:${LOG_NC} $*" >&2
}

# Warning message for non-critical issues
warn() {
    echo -e "${LOG_YELLOW}[$(eval ${LOG_DATE_CMD})] WARN:${LOG_NC} $*" >&2
}

# Error message followed by immediate script termination
error() {
    echo -e "${LOG_RED}[$(eval ${LOG_DATE_CMD})] ERROR:${LOG_NC} $*" >&2
    abort
}

# Variable guarded non-critical messages
vmsg()   { [[ "$1" == true ]] && msg "${@:2}"; }
vwarn()  { [[ "$1" == true ]] && warn "${@:2}"; }

# Command execution comined with messaging via first parameter
# example: echoexec echo command arg1 arg2
echoexec() {
    local printer="$1"
    local execargs="${@:2}"
    $printer "$execargs" && $execargs
}

# Variable guarded command execution
# example: vexec $dryrun command arg1 arg2
vexec() { [[ "$1" == true ]] || ${@:2}; }

# Variable guarded command execution with persistent messaging via first parameter
# example: echovexec echo $dryrun command arg1 arg2
echovexec() {
    local printer="$1"
    local execguard="$2"
    local execargs="${@:3}"
    $printer "$execargs"
    [[ "$execguard" == true ]] || $execargs
}

# Command execution with variable guarded messaging via first parameter
# example: vechoexec $verbose echo command arg1 arg2
vechoexec() {
    local echoguard="$1"
    local printer="$2"
    local execargs="${@:3}"
    [[ "$echoguard" == true ]] || $printer "$execargs"
    $execargs
}

# Variable guarded command execution with variable guarded messaging via first parameter
# example: vechoexec $verbose echo $dryrun command arg1 arg2
vechovexec() {
    local echoguard="$1"
    local printer="$2"
    local execguard="$3"
    local execargs="${@:4}"
    [[ "$echoguard" == true ]] || $printer "$execargs"
    [[ "$execguard" == true ]] || $execargs
}


# Privilege guard - when operations require root access
check_root() {
    if [[ $EUID -ne 0 ]]; then
       error "This script must be run as root."
    fi
}

# Secure dependency check for required binaries
check_dep() {
    for bin in "$@"; do
        if ! command -v "$bin" &> /dev/null; then
            error "Missing dependency: $bin. Install it before running."
        fi
    done
}

# Check if the file is being sourced (vs. being executed)
is_sourced() {
    [[ "${FUNCNAME[-1]}" == "source" ]]
    return $?
}

