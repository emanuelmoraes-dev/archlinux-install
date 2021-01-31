# archlinux-install
Installation script for Arch Linux

## quick start
### clone the git project
```sh
git clone https://github.com/emanuelmoraes-dev/archlinux-install.git
```
### enter the project directory
```sh
cd archlinux-install
```
### copy the environment variables file
```sh
cp env-example.sh env.sh
```
### customize variables
```sh
nano env.sh
```
### install arch linux
```sh
./install.sh
```
### copies the scripts to the installed system
```sh
cp *.sh /mnt/root
```
### enters the installed system
```sh
arch-chroot /mnt /bin/bash
```
### performs final system configurations
```sh
/root/final-config.sh
```

## Important
Attention! If you do not have another Linux system with a boot loader configured, you will need to configure a boot loader (grub, rEFInd, etc.) manually

## Tips For Install and Setting GRUB:
The following are tips on how to install and configure grub after installing and configuring the system. The following commands are generic and should work in most circumstances. If you have any questions or encounter any problems, visit the link <https://wiki.archlinux.org/index.php/GRUB_>
### For UEFI non IA32
```sh
pacman -Sy grub os-prober dosfstools efibootmgr mtools
```
```
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
```
```sh
grub-mkconfig -o /boot/grub/grub.cfg
```
### For UEFI IA32
```
pacman -S grub os-prober dosfstools efibootmgr mtools
```
```sh
grub-install --target=i386-efi --efi-directory=/boot/efi --bootloader-id=GRUB
```
```sh
grub-mkconfig -o /boot/grub/grub.cfg
```
### For non UEFI
```sh
pacman -S grub os-prober
```
```sh
grub-install --target=i386-pc /dev/sda
```
```sh
grub-mkconfig -o /boot/grub/grub.cfg
```

## API

### ```./install.sh [--help | --version] [<environment-variables-file>]```

Install and configure arch linux

#### params
 * --help:                     Shows all options
 * --version:                  Shows the current version
 * \<environment-variables-file\>: Name of the file containing the environment variables with the information needed to install and configure Arch Linux

### ```./final-config.sh [--help | --version] [<environment-variables-file>]```

Performs final system configurations for Arch Linux

#### params
 * --help:                     Shows all options
 * --version:                  Shows the current version
 * \<environment-variables-file\>: Name of the file containing the environment variables with the information needed to install and configure Arch Linux
