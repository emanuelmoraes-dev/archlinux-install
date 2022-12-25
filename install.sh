#!/usr/bin/env bash

VERSION=0.1.0

# archlinux-install/install@0.1.0
#
# Installation script for Arch Linux
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
#     ./install.sh
#
# Example 2:
#     ./install.sh env.sh
#
# Autor: Emanuel Moraes de Almeida
# Email: emanuelmoraes297@gmail.com
# Github: https://github.com/emanuelmoraes-dev

[ -z "$ARCH_DIRNAME" ] && ARCH_DIRNAME="$(dirname "$0")"
source "$ARCH_DIRNAME/install.sources.sh"

# exec main function
install.main "$@"
