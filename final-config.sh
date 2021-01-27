#!/usr/bin/env bash

# archlinux-install/final-config@0.0.6
#
# Performs final system configurations
#
# Parameters:
#      [<environment-variables-file>]
#
#      environment-variables-file: Name of the file containing the environment variables with
#                                  the information needed to install and configure Arch Linux.
#                                  Default value: env.sh
#
# Example 1:
#     ./final-config
#
# Example 2:
#     ./final-config env.sh

# CONSTANT
[ -z "$ARCH_DIRNAME" ] && ARCH_DIRNAME="$(dirname "$0")"
[ -z "$ARCH_DEFAULT_ENV_FILE" ] && ARCH_DEFAULT_ENV_FILE="env.sh"
[ -z "$ARCH_ENV_FILE_INVALID_CODE" ] && ARCH_ENV_FILE_INVALID_CODE=1
[ -z "$ARCH_ENV_FILE_INVALID_MESSAGE" ] && ARCH_ENV_FILE_INVALID_MESSAGE="Environment variables file invalid or not found"
[ -z "$ARCH_URL_CHECK_INTERNET" ] && ARCH_URL_CHECK_INTERNET="http://google.com"

# get the arguments and initialize the global variables
#
# exports:
#   * __env_file
function get_args {
    __env_file="$1"
    [ -z "$__env_file" ] && __env_file="$ARCH_DEFAULT_ENV_FILE"
    __env_file="$ARCH_DIRNAME/$__env_file"
}

function check_internet {
    curl -sSf "$ARCH_URL_CHECK_INTERNET" 1> /dev/null 2>&1 ||
    return $ARCH_ERR_NO_INTERNET_CONNECTION_CODE
}

# perform configurations based on variables exported by
# "get_args" and the environment file (__env_file)
#
# imports:
#   * __env_file
function config {
    source "$__env_file" || (
        printf >&2 "$ARCH_ENV_FILE_INVALID_MESSAGE"
        exit $ARCH_ENV_FILE_INVALID_CODE
    ) &&
    check_internet &&
    if [ "$ARCH_LOADKEYS" ]; then
        loadkeys "$ARCH_LOADKEYS"
    fi ||
    return $?
}

# configure datetime
function config_datetime {
    if [ -z "$ARCH_LOCALTIME" ]; then
        return $ARCH_ERR_LOCALTIME_NOT_INFORMED_CODE
    fi &&
    ln -sf "$ARCH_LOCALTIME" /etc/localtime &&
    if [ "${#ARCH_HWCLOCK_ARGS[@]}" -gt 0 ]; then
        hwclock "${ARCH_HWCLOCK_ARGS[@]}"
    fi ||
    return $?
}

# configure system languages
function config_languages {
    local i
    local lang

    for ((i = 0; i < "${#ARCH_LANGUAGES[@]}"; i++)); do
        lang="${ARCH_LANGUAGES[i]}" &&
        sed -i "s/#$lang/$lang/" /etc/locale.gen
    done &&

    locale-gen &&
    printf 'LANG=%s' "$ARCH_LANG" > /etc/locale.conf ||

    return $?
}

# set the root password
function config_root_password {
    printf "\n$ARCH_INFORM_THE_ROOT_PASSWORD\n" &&
    passwd root ||
    return $?
}

# performs final settings
function run {
    printf '%s' "$ARCH_HOSTNAME" > /etc/hostname &&
    config_datetime &&
    config_languages &&
    config_root_password &&
    pacman -Sy "${ARCH_PACKAGES[@]}" &&
    systemctl enable NetworkManager.service ||
    return $?
}

# main function
function main {
    local err

    # exports:
    #   * __env_file
    get_args "$@" &&

    # imports:
    #   * __env_file
    config &&

    run &&

    printf '%s' "$ARCH_FINAL_CONFIG_MESSAGE" || (
        err=$?
        case "$err" in
            $ARCH_ERR_LOCALTIME_NOT_INFORMED_CODE) (
                printf >&2 "$ARCH_ERR_LOCALTIME_NOT_INFORMED_MESSAGE\n" "$ARCH_ERR_LOCALTIME_NOT_INFORMED_CODE"
                exit $ARCH_ERR_LOCALTIME_NOT_INFORMED_CODE
            );;

            $ARCH_ERR_NO_INTERNET_CONNECTION_CODE) (
                printf >&2 "$ARCH_ERR_NO_INTERNET_CONNECTION_MESSAGE\n" "$ARCH_ERR_NO_INTERNET_CONNECTION_CODE"
                exit $ARCH_ERR_NO_INTERNET_CONNECTION_CODE
            );;

            *) (
                printf >&2 "$ARCH_ERR_UNEXPECTED_MESSAGE\n" "$err"
                exit $err
            );;
        esac
    )
}

# exec main function
main "$@"
