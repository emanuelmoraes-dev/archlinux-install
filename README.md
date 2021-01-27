# archlinux-install
Installation script for Arch Linux

## quick start
```sh
cp env-example.sh env.sh
nano env.sh # customize environment variables for installation
./install.sh
cp ./env.sh ./final-config.sh /mnt/root
arch-chroot /mnt /bin/bash
/root/final-config.sh
```

## API
### ./install.sh
Install and configure arch linux
#### params
```sh
[<environment-variables-file>]
```

 * environment-variables-file: name of the file containing the environment variables with the information needed to install and configure Arch Linux

### ./final-config.sh
performs final system configurations
#### params
```sh
[<environment-variables-file>]
```

 * environment-variables-file: name of the file containing the environment variables with the information needed to install and configure Arch Linux
