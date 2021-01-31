#!/usr/bin/env bash

# archlinux-install/install@0.0.5
#
# Installation script for Arch Linux
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

# creates partitions
function create_partitions {
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
function partitions_get_device {
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
            printf "$ARCH_DEVICE_NAME" "$1" "$2"
        elif [ "$1" ]; then
            printf "$ARCH_DEVICE_NAME_WITHOUT_ARGS" "$1"
        elif [ "$2" ]; then
            printf "$ARCH_DEVICE_NAME_WITHOUT_FORMAT" "$2"
        fi &&

        printf '$>> ' &&
        read __device_name &&

        if ! lsblk -o name | grep "$__device_name" 1> /dev/null 2>&1; then
            printf >&2 "$ARCH_INVALID_DEVICE_MESSAGE\n" "$__device_name" &&
            __device_name=
        fi
    done &&
    
    __device_name="/dev/$__device_name" ||

    return $?
}

# format partitions
function format_partitions {
    local i
    local format_name
    local args
    local __device_name

    for ((i = 0; i < "${#ARCH_FORMAT_PARTITIONS_FORMAT_NAMES[@]}"; i++)); do
        format_name="${ARCH_FORMAT_PARTITIONS_FORMAT_NAMES[i]}"
        args="${ARCH_FORMAT_PARTITIONS_ARGS[i]}"

        # exports
        #   * __device_name
        partitions_get_device "$format_name" "$args" &&

        "mkfs$format_name" $args "$__device_name"
    done ||

    return $?
}

# mount partitions
function mount_partitions {
    local i
    local point
    local args
    local __device_name

    for ((i = 0; i < "${#ARCH_MOUNT_PARTITIONS_POINTS[@]}"; i++)); do
        point="${ARCH_MOUNT_PARTITIONS_POINTS[i]}"
        args="${ARCH_MOUNT_PARTITIONS_ARGS[i]}"

        # exports
        #   * __device_name
        partitions_get_device "$point" "$args" &&

        mkdir -p "${ARCH_MOUNT_FOLDER}${point}" &&
        mount $args "$__device_name" "${ARCH_MOUNT_FOLDER}${point}"
    done ||

    return $?
}

# configure fstab
function fstab {
    local enter

    genfstab "${ARCH_GENFSTAB_ARGS[@]}" "$ARCH_MOUNT_FOLDER" >> "$ARCH_MOUNT_FOLDER/etc/fstab" &&
    if [ "$ARCH_FSTAB_EDIT" ]; then
        "$ARCH_FSTAB_EDIT" "$ARCH_MOUNT_FOLDER/etc/fstab"
    fi &&
    return $?
}

# install the Arch Linux
function install {
    create_partitions &&
    format_partitions &&
    mount_partitions &&
    pacstrap "$ARCH_MOUNT_FOLDER" "${ARCH_PACSTRAP_PACKAGES[@]}" &&
    fstab ||
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

    install &&

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

# exec main function
main "$@"
