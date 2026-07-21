# Config files for building NixOS for my machines
## Installation instructions
### Prepare and boot NixOS live disk
1. Download NixOS 26.05 (or newer) `.iso` file
2. Burn to flash drive using `sudo dd if=/path/to/filename.iso of=/dev/sdX bs=4M status=progress`
3. Boot to flash drive and run the live drive
### Partition setup
In this example our two partitions are `sda1` and `sda2` from device `sda`. Replace with equivalent for specific hardware.
1. `sudo fdisk /dev/sda`
2. `g` (gpt disk label)
3. `n`
4. `1` (partition number [1/128])
5. `2048` first sector
6. `+500M` last sector (boot sector size)
7. `t`
8. `1` (EFI System)
9. `n`
10. `2`
11. default (fill up partition)
12. default (fill up partition)
13. `w` (write)
14. `sudo mkfs.fat -F 32 /dev/sda1`
15. `sudo fatlabel /dev/sda1 NIXBOOT`
16. `sudo mkfs.ext4 /dev/sda2 -L NIXROOT`
### Mount partitions
1. `sudo mount /dev/disk/by-label/NIXROOT /mnt`
2. `sudo mkdir -p /mnt/boot`
3. `sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot`
### Create swap file
1. `sudo dd if=/dev/zero of=/mnt/.swapfile bs=1024 count=2097152` (2GB size)
2. `sudo chmod 600 /mnt/.swapfile`
3. `sudo mkswap /mnt/.swapfile`
4. `sudo swapon /mnt/.swapfile`
### Configure system
**[F]** denotes steps to do if on an entirely new device ( **[F]** resh). The hostname of the current machine used in this example is `currHostName` and user is `userName`:
1. `sudo nixos-generate-config --root /mnt` **[F]**
2. `cp /etc/nixos/hardware-configuration.nix ~/` **[F]**
3. `sudo rm -rf /etc/nixos` **[F]**
4. `git clone https://github.com/ViktorWalter/nixos-config.git ~/`
5. `sudo mv ~/nixos-dofig /etc/nixos`
6. `cd /etc/nixos`
7. `mkdir hosts/hostName` **[F]**
8. `cp ~/hardware-configuration.nix ./hosts/currHostName/` **[F]**
9. `cp ./hosts/viktorPC/configuration.nix ./hosts/currHostName/` **[F]**
10. edit `./hosts/currHostName` according to the machine specs **[F]**
11. edit `./flake.nix` and add `currHostName = mkHost {hostName = "currHostName"; };` to ` nixosConfigurations` **[F]**
12. `sudo nixos-install --flake /mnt/etc/nixos#currHostName`
13. when prompted, insert root password
14. `sudo reboot` to new OS installation, remove flash drive
### Post installation steps
TODO: Ideally, these should all be automated
1. if sudo password for `userName` is not accepted, log in as `root` and use `sudo passwd userName`
2. in `neovim`, call `:PlugInstall`
3. `cd /etc/nixos && git remote set-url origin git@github.com:ViktorWalter/nixos-config.git`
4. Set up `ssh` keys (for **[F]** use e.g. `ssh-keygen -t ed25519 -C "currHostName_key"` and distribute the public key)
5. Migrate firefox profile
