#!/usr/bin/env bash

VERSION=0.0.13

# archlinux-install/final-config@0.0.13
#
# Performs final system configurations in Arch Linux
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
#     ./final-config
#
# Example 2:
#     ./final-config env.sh
#
# Autor: Emanuel Moraes de Almeida
# Email: emanuelmoraes297@gmail.com
# Github: https://github.com/emanuelmoraes-dev

[ -z "$ARCH_DIRNAME" ] && ARCH_DIRNAME="$(dirname "$0")"
source "$ARCH_DIRNAME/final-config.sources.sh"

# exec main function
final-config.main "$@"
