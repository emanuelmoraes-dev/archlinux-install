#!/usr/bin/env bash

VERSION=0.1.0

# archlinux-install/install@0.1.0
#
# Installation functions and variables for Arch Linux
#
# Autor: Emanuel Moraes de Almeida
# Email: emanuelmoraes297@gmail.com
# Github: https://github.com/emanuelmoraes-dev

function install.helpout {
    printf '%s\n' "archlinux-install/install@$VERSION"
    printf '\n'
    printf '%s\n' "Installation script for Arch Linux"
    printf '\n'
    printf '%s\n' "Parameters:"
    printf '%s\n' "     [--help | --version] [<environment-variables-file>]"
    printf '\n'
    printf '%s\n' "     --help:                     Shows all options"
    printf '%s\n' "     --version:                  Shows the current version"
    printf '%s\n' "     <environment-variables-file>: Name of the file containing the environment variables with"
    printf '%s\n' "                                 the information needed to install and install.configure Arch Linux."
    printf '%s\n' "                                 Default value: env.sh"
    printf '\n'
    printf '%s\n' "Example 1:"
    printf '%s\n' "    ./install.sh"
    printf '\n'
    printf '%s\n' "Example 2:"
    printf '%s\n' "    ./install.sh env.sh"

    if [ "$1" = "--autor" ]; then
        printf '\n%s\n' "Autor: Emanuel Moraes de Almeida"
        printf '%s\n' "Email: emanuelmoraes297@gmail.com"
        printf '%s\n' "Github: https://github.com/emanuelmoraes-dev"
    fi
}

# CONSTANT
[ -z "$ARCH_DIRNAME" ] && ARCH_DIRNAME="$(dirname "$0")"
[ -z "$ARCH_DEFAULT_ENV_FILE" ] && ARCH_DEFAULT_ENV_FILE="env.sh"
[ -z "$ARCH_ENV_FILE_INVALID_CODE" ] && ARCH_ENV_FILE_INVALID_CODE=1
[ -z "$ARCH_ENV_FILE_INVALID_MESSAGE" ] && ARCH_ENV_FILE_INVALID_MESSAGE="Environment variables file invalid or not found"
[ -z "$ARCH_URL_CHECK_INTERNET" ] && ARCH_URL_CHECK_INTERNET="https://google.com"

# trim whitespace
function install.trim {
    local var="$@"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

# get the arguments and initialize the global variables
#
# exports:
#   * __env_file
function install.get_args {
    if [ "$1" = "--version" ]; then
        printf 'version: %s\n' "$VERSION"
        exit 0
    elif [ "$1" = "--help" ]; then
        install.helpout --autor
        exit 0
    fi

    __env_file="$1"
    [ -z "$__env_file" ] && __env_file="$ARCH_DEFAULT_ENV_FILE"
    __env_file="$ARCH_DIRNAME/$__env_file"
}

function install.check_internet {
    curl -sSf "$ARCH_URL_CHECK_INTERNET" 1> /dev/null 2>&1 ||
    return $ARCH_ERR_NO_INTERNET_CONNECTION_CODE
}

# perform configurations based on variables exported by
# "install.get_args" and the environment file (__env_file)
#
# imports:
#   * __env_file
function install.config {
    source "$__env_file" || (
        printf >&2 "$ARCH_ENV_FILE_INVALID_MESSAGE"
        exit $ARCH_ENV_FILE_INVALID_CODE
    ) &&
    install.check_internet &&
    if [ "$ARCH_LOADKEYS" ]; then
        loadkeys "$ARCH_LOADKEYS"
    fi ||
    return $?
}

# creates partitions
function install.create_partitions {
    if [ "$ARCH_CREATE_PARTITIONS_COMMAND" ]; then
        "$ARCH_CREATE_PARTITIONS_COMMAND" "${ARCH_CREATE_PARTITIONS_ARGS[@]}"
    fi ||
    return $?
}

# get the name of the device to be formatted
#
# arguments
#   1: format_name
#   2: args
# exports:
#   * __device_name
function install.format_get_device {
    __device_name=

    if [ "$ARCH_LIST_PARTITIONS_COMMAND" ]; then
        if [ "$ARCH_LIST_LESS" -eq 0 ]; then
            "$ARCH_LIST_PARTITIONS_COMMAND" "${ARCH_LIST_PARTITIONS_ARGS[@]}"
        else
            "$ARCH_LIST_PARTITIONS_COMMAND" "${ARCH_LIST_PARTITIONS_ARGS[@]}" | less
        fi
    fi &&

    while [ -z "$__device_name" ]; do
	    printf '\n'
        if [ "$1" ] && [ "$2" ]; then
            printf "$ARCH_FORMAT_DEVICE_NAME" "$1" "$2"
        elif [ "$1" ]; then
            printf "$ARCH_FORMAT_DEVICE_NAME_WITHOUT_ARGS" "$1"
        elif [ "$2" ]; then
            printf "$ARCH_FORMAT_DEVICE_NAME_WITHOUT_FORMAT" "$2"
        fi &&

        printf '$>> ' &&
        read __device_name &&
        __device_name="$(install.trim "$__device_name")" &&

        if [ -z "$__device_name" ] || ! lsblk -o name | grep "$__device_name" 1> /dev/null 2>&1; then
            printf >&2 "$ARCH_INVALID_DEVICE_MESSAGE\n" "$__device_name" &&
            __device_name=
        fi
    done &&
    
    __device_name="/dev/$__device_name" ||

    return $?
}

# format partitions
function install.format_partitions {
    local i
    local format_name
    local args
    local __device_name

    for ((i = 0; i < "${#ARCH_FORMAT_PARTITIONS_FORMAT_NAMES[@]}"; i++)); do
        format_name="${ARCH_FORMAT_PARTITIONS_FORMAT_NAMES[i]}"
        args="${ARCH_FORMAT_PARTITIONS_ARGS[i]}"

        # exports
        #   * __device_name
        install.format_get_device "$format_name" "$args" &&

        "mkfs$format_name" $args "$__device_name"
    done ||

    return $?
}

# get the name of the device to be mounted
#
# arguments
#   1: mount_point
#   2: args
# exports:
#   * __device_name
function install.mount_get_device {
    __device_name=

    if [ "$ARCH_LIST_PARTITIONS_COMMAND" ]; then
        if [ "$ARCH_LIST_LESS" -eq 0 ]; then
            "$ARCH_LIST_PARTITIONS_COMMAND" "${ARCH_LIST_PARTITIONS_ARGS[@]}"
        else
            "$ARCH_LIST_PARTITIONS_COMMAND" "${ARCH_LIST_PARTITIONS_ARGS[@]}" | less
        fi
    fi &&

    while [ -z "$__device_name" ]; do
	    printf '\n'
        if [ "$1" ] && [ "$2" ]; then
            printf "$ARCH_MOUNT_DEVICE_NAME" "$1" "$2"
        elif [ "$1" ]; then
            printf "$ARCH_MOUNT_DEVICE_NAME_WITHOUT_ARGS" "$1"
        fi &&

        printf '$>> ' &&
        read __device_name &&
        __device_name="$(install.trim "$__device_name")" &&

        if [ -z "$__device_name" ] || ! lsblk -o name | grep "$__device_name" 1> /dev/null 2>&1; then
            printf >&2 "$ARCH_INVALID_DEVICE_MESSAGE\n" "$__device_name" &&
            __device_name=
        fi
    done &&
    
    __device_name="/dev/$__device_name" ||

    return $?
}

# mount partitions
function install.mount_partitions {
    local i
    local point
    local args
    local __device_name

    for ((i = 0; i < "${#ARCH_MOUNT_PARTITIONS_POINTS[@]}"; i++)); do
	    name="${ARCH_MOUNT_PARTITIONS_NAMES[i]}"
        point="${ARCH_MOUNT_PARTITIONS_POINTS[i]}"
        args="${ARCH_MOUNT_PARTITIONS_ARGS[i]}"

        # exports
        #   * __device_name
        install.mount_get_device "$point" "$args" &&

        mkdir -p "${ARCH_MOUNT_FOLDER}${point}" &&
        "mount$name" $args "$__device_name" "${ARCH_MOUNT_FOLDER}${point}"
    done ||

    return $?
}

# configure fstab
function install.fstab {
    local enter

    genfstab "${ARCH_GENFSTAB_ARGS[@]}" "$ARCH_MOUNT_FOLDER" >> "$ARCH_MOUNT_FOLDER/etc/fstab" &&
    if [ "$ARCH_FSTAB_EDIT" ]; then
        "$ARCH_FSTAB_EDIT" "$ARCH_MOUNT_FOLDER/etc/fstab"
    fi &&
    return $?
}

# install the Arch Linux
function install.run {
    install.create_partitions &&
    install.format_partitions &&
    install.mount_partitions &&
    pacstrap "$ARCH_MOUNT_FOLDER" "${ARCH_PACSTRAP_PACKAGES[@]}" &&
    install.fstab ||
    return $?
}

# Main installation function for Arch Linux
#
# Parameters:
#      [--help | --version] [<environment-variables-file>]
#
#      --help:                     Shows all options
#      --version:                  Shows the current version
#      <environment-variables-file>: Name of the file containing the environment variables with
#                                  the information needed to install and configure Arch Linux.
#                                  Default value: env.sh
#
# Example 1:
#     install.main
#
# Example 2:
#     install.main env.sh
function install.main {
    local err

    # exports:
    #   * __env_file
    install.get_args "$@" &&

    # imports:
    #   * __env_file
    install.config &&

    install.run &&

    printf "$ARCH_FINAL_INSTALLATION_MESSAGE" || (
        err=$?
        case "$err" in
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
