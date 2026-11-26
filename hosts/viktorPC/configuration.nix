# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, fresh-pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nextcloud.nix
    ];

  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNW010T8_BTNH846407JQ1P0B";
    useOSProber = true; 
    gfxmodeBios = "auto";
    extraConfig = ''
      set gfxpayload=keep
    '';
    extraEntries = ''
      menuentry "Windows 10" {
        insmod part_msdos
          insmod ntfs
          insmod chain
          set root=(hd0,1)
          chainloader +1
      }
    '';
    configurationLimit = 10; #max N old derivations stored
  };

  boot.kernelPackages = fresh-pkgs.linuxPackages_7_3;

  swapDevices = [
    { device = "/swapfile"; size = 8192; } 
  ];

  #Drive mounting 
  fileSystems."/home/viktor/HDD_X" = {
    device = "/dev/disk/by-uuid/0D99011D4D257278";
    fsType = "ntfs";
    options = [
      "nofail"
    ];
  };
  fileSystems."/home/viktor/HDD_Y" = {
    device = "/dev/disk/by-uuid/19AE099C2CFFA419";
    fsType = "ntfs";
    options = [
      "nofail"
    ];
  };
  fileSystems."/home/viktor/SSD_S" = {
    device = "/dev/disk/by-uuid/44D5B4C74B893D51";
    fsType = "ntfs";
    options = [
      "nofail"
    ];
  };
  fileSystems."/home/viktor/Win_DATA" = {
    device = "/dev/disk/by-uuid/D06873F66873D9A4";
    fsType = "ntfs";
    options = [
      "nofail"
    ];
  };


  #GPU
  hardware.graphics.enable = true;
  hardware.amdgpu.opencl.enable = true;

  #Screen layout
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xrandr}/bin/xrandr --output DP-3 --right-of HDMI-1
    ${pkgs.xrandr}/bin/xrandr --output HDMI-1 --primary
    ${pkgs.xrandr}/bin/xrandr --output HDMI-1 --set "Broadcast RGB" "Full"
  '';

  #Audio
  services.pulseaudio.extraConfig = ''
    unload-module module-switch-on-port-available
    set-card-profile alsa_card.pci-0000_03_00.1  output:hdmi-stereo-extra4
    set-default-sink alsa_output.pci-0000_03_00.1.hdmi-stereo-extra4
    '';

  #threema
  services.flatpak.update.onActivation = true;
  services.flatpak.packages = [
    {
      flatpakref = "https://releases.threema.ch/flatpak/threema-desktop/ch.threema.threema-desktop.flatpakref";
      sha256 = "0lghiiiphbkqgiprqirxifldvix0j4k04jh1z9f911shrzjgqq4s"; #get with nix-prefetch-url
    }
  ];
  #to allow threema to store keys and allow persistant login
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true; # or whatever your login PAM service is called (e.g. "sddm", "gdm", "greetd")

  nixpkgs.config.allowUnfree = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  environment.systemPackages = (with pkgs; [
    blender
    prusa-slicer
    kicad
    freecad
    obsidian
    btop-rocm
    davinci-resolve
    amdgpu_top
    deluge
    lutris
    discord
    cinny-desktop
    claude-code
  ]) ++
  ( with fresh-pkgs; [
    opencode
    opencode-claude-auth
  ]
  )
  ;
  
  services.llama-cpp = {
    enable = true;
# Pick ONE package depending on your GPU backend:
    package = pkgs.llama-cpp-rocm;      # AMD ROCm (you already have hardware.amdgpu.opencl.enable)
  # package = pkgs.llama-cpp-vulkan; # fallback if ROCm misbehaves on your card

    port = 8090;
    modelsPreset = {
      "Qwen3.8-27B" = {
        hf-repo = "unsloth/Qwen3.8-27B-GGUF";
        hf-file = "Qwen3.8-27B-UD-Q3_K_XL.gguf";   # 3-bit dynamic quant
          alias = "qwen3.8-27b-3bit";                 # name exposed via the API
          temp = "0.7";
        top-p = "0.8";
        top-k = "20";
        presence-penalty = "1.5"; 

        flash-attn = "on";
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";

        reasoning-budget = "2048";
        
        no-mmproj = "true";
        ctx-size = "32768";   # total context window, in tokens
        parallel = "1";       # don't split it across concurrent slots
        batch-size = "512";
        ubatch-size = "512";

        no-cache-prompt = "true";   # actually disables checkpoint/prompt-cache reuse

        #no-kv-offload = "true";   # KV cache lives in system RAM
        mlock = "true";           # pin weights in RAM, never paged out

        threads = "6";
        threads-batch = "12";
      };
    };
  };

}

