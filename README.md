# Config files for building NixOS for my machines
<img src="https://github.com/NixOS/nixos-artwork/blob/master/logo/nixos.svg" width="350" alt="NixOS logo">

## Installation instructions
### Prepare and boot NixOS live disk
1. Download [NixOS](https://nixos.org/download/) 26.05 (or newer) `.iso` file for manual installation
2. Burn to flash drive using `sudo dd if=/path/to/filename.iso of=/dev/sdX bs=4M status=progress`
3. Boot to flash drive and run the live drive

### Base system preparations
<details>
<summary>Set up file system and swap</summary>

#### Partition setup
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

#### Mount partitions
1. `sudo mount /dev/disk/by-label/NIXROOT /mnt`
2. `sudo mkdir -p /mnt/boot`
3. `sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot`

#### Create swap file
1. `sudo dd if=/dev/zero of=/mnt/.swapfile bs=1024 count=2097152` (2GB size)
2. `sudo chmod 600 /mnt/.swapfile`
3. `sudo mkswap /mnt/.swapfile`
4. `sudo swapon /mnt/.swapfile`

</details>

### Configure system
**[F]** denotes steps to do if on an entirely new device ( **[F]** resh). The hostname of the current machine used in this example is `currHostName` and user is `userName`:
1. `sudo nixos-generate-config --root /mnt` **[F]**
2. `cp /etc/nixos/hardware-configuration.nix ~/` **[F]**
3. `sudo rm -rf /etc/nixos` **[F]**
4. `git clone https://github.com/ViktorWalter/nixos-config.git ~/`
5. `sudo mv ~/nixos-config /etc/nixos`
6. `cd /etc/nixos`
7. `mkdir hosts/currHostName` **[F]**
8. `cp ~/hardware-configuration.nix ./hosts/currHostName/` **[F]**
9. `cp ./hosts/viktorPC/configuration.nix ./hosts/currHostName/` **[F]** (or choose another config as a template)
10. edit `./hosts/currHostName/configuration.nix` according to the machine specs **[F]**
11. edit `./flake.nix` and add `currHostName = mkHost {hostName = "currHostName"; };` to ` nixosConfigurations` **[F]**
12. connect to internet - if only WiFi is available do e.g. `nmcli device wifi connect SSID password PASSWORD`
13. `sudo nixos-install --flake /mnt/etc/nixos#currHostName`
14. when prompted, insert root password
15. `sudo reboot` to new OS installation, remove flash drive
### Post installation steps
TODO: Ideally, these should all be automated
1. if sudo password for `userName` is not accepted, log in as `root` and use `sudo passwd userName`
2. `cd /etc/nixos && git remote set-url origin git@github.com:ViktorWalter/nixos-config.git`
3. Set up `ssh` keys (for **[F]** use e.g. `ssh-keygen -t ed25519 -C "currHostName_key"` and distribute the public key)
4. Add, commit and push new configs and changes from `/etc/nixos`
5. Migrate firefox profile
6. In `neovim`, call `:PlugInstall`

## File structure
The setup is based on [Nix Flakes](https://wiki.nixos.org/wiki/NixOS_system_configuration#Defining_NixOS_as_a_flake) .
- The "main" file is `./flake.nix` with the most high-level settings.
`.flake.nix` then references `./configuration.nix`, one of `./hosts/currHostName/configuration.nix` files and `./home.nix`.
The file is associated with `flake.lock` that locks down specific versions of packages.
- `./configuration.nix` contains basic configurations that should apply to all my machines.
- `./hosts/currHostName/configuration.nix` contains configuration extensions specific to a given machine and it references the associated `./hosts/currHostName/hardware-configuration.nix` generated in a fresh install.
- `./home.nix` is a config for [Home Manager](https://wiki.nixos.org/wiki/Home_Manager) that references module files from `./home-manager` containing configurations of various programs

In some files, the `hostName` variable is used ad-hoc to make some steps specific to a certain machine
## Usage notes
- Whenever you make a change in these configs, run `sudo nixos-rebuild switch` to apply them.
- Most program configurations such as for `i3`, `neovim`, etc. are generated from `.nix` files in `./home-manager`.
These are intended to be edited with care such that they remain universally suitable for my future machines.
- For "ad-hoc" changes that are host-specific, I source sub-configs such as `~/.my.vimrc` which are linked to host-specific files such as `./home-manager/i3/currHostName-dotvimrc` using the `.nix` configs.
This allows me to do spurious, non-universal additions or changes to program behavior from `~/` and then commit the changes from `/etc/nixos`.
