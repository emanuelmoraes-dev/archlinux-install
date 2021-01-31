#!/usr/bin/env bash

# INSTALLATION

## KEYBOARD
### to list all available map.gz
#### `ls /usr/share/kbd/keymaps/**/*.map.gz`
### example
#### ARCH_LOADKEYS=br-abnt2
ARCH_LOADKEYS=

## CREATE PARTITIONS
ARCH_CREATE_PARTITIONS_COMMAND=cfdisk
ARCH_CREATE_PARTITIONS_ARGS=()

## FORMAT PARTITIONS (via mkfs)
### format names
#### example
##### ARCH_FORMAT_PARTITIONS_FORMAT_NAMES=(.fat .ext4)
ARCH_FORMAT_PARTITIONS_FORMAT_NAMES=()
### arguments
#### example
##### ARCH_FORMAT_PARTITIONS_ARGS=(-F32 '')
ARCH_FORMAT_PARTITIONS_ARGS=()

## MOUNT PARTITIONS
ARCH_MOUNT_FOLDER=/mnt
ARCH_MOUNT_PARTITIONS_POINTS=(/)
ARCH_MOUNT_PARTITIONS_ARGS=('')

## LIST PARTITIONS
ARCH_LIST_PARTITIONS_COMMAND=fdisk
ARCH_LIST_PARTITIONS_ARGS=(-l)
ARCH_LIST_LESS=0 # not 0 for use "| less"

## PACSTRAP PACKAGES
ARCH_PACSTRAP_PACKAGES=(base base-devel linux linux-firmware)

## FSTAB
ARCH_GENFSTAB_ARGS=(-U)
ARCH_FSTAB_EDIT=nano

# FINAL CONFIG

## set hostname
ARCH_HOSTNAME=arch

## set /etc/hosts
ARCH_HOSTS="\
127.0.0.1         localhost.localdomain         localhost
::1               localhost.localdomain         localhost
127.0.0.1         $ARCH_HOSTNAME.localdomain    $ARCH_HOSTNAME
::1               $ARCH_HOSTNAME.localdomain    $ARCH_HOSTNAME
"

## set zoneinfo
### example
#### ARCH_LOCALTIME=/usr/share/zoneinfo/America/Sao_Paulo
ARCH_LOCALTIME=

## set system clock
### UTC
ARCH_HWCLOCK_ARGS=(--systohc --utc)
### localtime
#### ARCH_HWCLOCK_ARGS=(--systohc --localtime)

## define supported languages
### to list all languages available
#### cat /etc/locale.gen
ARCH_LANGUAGES=(
    en_US.UTF-8 UTF-8
)

## sets the system language
ARCH_LANG="en_US.UTF-8"

## PACKAGES
ARCH_PACKAGES=(
    net-tools
    networkmanager
    nano
    alsa-utils
    pulseaudio
    pulseaudio-alsa
    bluez
    bluez-utils
  # vim
  # neovim
  # git
  # xf86-video-intel # for intel
  # mesa
  # xorg
  # xorg-server
  # gnome
  # gnome-extra
  # mate
  # mate-extra
  # lightdm
  # lightdm-gtk-greeter
)

# COLORS
ARCH_END_COLOR="\e[m"
ARCH_RED="\e[31;1m"
ARCH_GREEN="\e[32;1m"
ARCH_YELLOW="\e[33;1m"
ARCH_BLUE="\e[34;1m"
ARCH_PINK="\e[35;1m"
ARCH_CYAN="\e[36;1m"
ARCH_WHITE="\e[37;1m"

# THEMES
ARCH_ERROR_THEME="$ARCH_RED"
ARCH_QUESTION_THEME="$ARCH_CYAN"
ARCH_MESSAGE_THEME="$ARCH_GREEN"

# ERROS
## UNEXPECTED
ARCH_ERR_UNEXPECTED_MESSAGE="${ARCH_ERROR_THEME}An unexpected error has occurred [Code %s]${ARCH_END_COLOR}"
## NO_INTERNET_CONNECTION
ARCH_ERR_NO_INTERNET_CONNECTION_CODE=101
ARCH_ERR_NO_INTERNET_CONNECTION_MESSAGE="${ARCH_ERROR_THEME}NO INTERNET CONNECTION [Code %s]${ARCH_END_COLOR}"
## ARCH_LOCALTIME_NOT_INFORMED
ARCH_ERR_LOCALTIME_NOT_INFORMED_CODE=102
ARCH_ERR_LOCALTIME_NOT_INFORMED_MESSAGE="${ARCH_ERROR_THEME}ARCH_LOCALTIME is not present in the environment variable file! [Code %s]${ARCH_END_COLOR}"

# WARNINGS
ARCH_INVALID_DEVICE_MESSAGE="${ARCH_ERROR_THEME}Invalid \"%s\" device!${ARCH_END_COLOR}"

# QUESTIONS
## DEVICE NAME
ARCH_DEVICE_NAME="${ARCH_QUESTION_THEME}Write the name of the device to be formatted in \"%s\" with the arguments \"%s\":\nexample: sda1\n${ARCH_END_COLOR}"
ARCH_DEVICE_NAME_WITHOUT_ARGS="${ARCH_QUESTION_THEME}Write the name of the device to be formatted in \"%s\":\nexample: sda1\n${ARCH_END_COLOR}"
ARCH_DEVICE_NAME_WITHOUT_FORMAT="${ARCH_QUESTION_THEME}Write the name of the device with the arguments \"%s\":\nexample: sda1\n${ARCH_END_COLOR}"
ARCH_INFORM_THE_ROOT_PASSWORD="${ARCH_QUESTION_THEME}Inform the root password:${ARCH_END_COLOR}"

# MESSAGES
ARCH_FINAL_INSTALLATION_MESSAGE="${ARCH_MESSAGE_THEME}\
Arch Linux has been successfully installed!
For other necessary configurations to occur, run the command

$ cp ./*.sh '$ARCH_MOUNT_FOLDER/root' && arch-chroot '$ARCH_MOUNT_FOLDER' /bin/bash

After that, run the script

$ /root/final-config.sh [<environment-variables-file>]
${ARCH_END_COLOR}
"
ARCH_FINAL_CONFIG_MESSAGE="${ARCH_MESSAGE_THEME}\
Arch Linux has been successfully configured!

Attention! If you do not have another Linux system with a boot loader configured, you will need to configure a boot loader (grub, rEFInd, etc.) manually

# Tips for setting up grub:
## For UEFI non IA32
$ pacman -S grub os-prober dosfstools efibootmgr mtools
$ grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
$ grub-mkconfig -o /boot/grub/grub.cfg
## For UEFI IA32
$ pacman -S grub os-prober dosfstools efibootmgr mtools
$ grub-install --target=i386-efi --efi-directory=/boot/efi --bootloader-id=GRUB
$ grub-mkconfig -o /boot/grub/grub.cfg
## For non UEFI
$ pacman -S grub os-prober
$ grub-install --target=i386-pc /dev/sda
$ grub-mkconfig -o /boot/grub/grub.cfg

# Tips for setting up rEFInd (ONLY UEFI):
$ pacman -S refind
$ refind-install

Now you need to exit arch-chroot with the command

$ exit

After that, you will need to unmount all partitions and restart the computer, with the following command

$ umount -R '$ARCH_MOUNT_FOLDER' && shutdown -r -h now
${ARCH_END_COLOR}
"
