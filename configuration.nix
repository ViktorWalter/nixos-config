# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, hostName, athame-flake, insect-flake, my-scripts-package, klaxalk-scripts-package,... }:
  let
    system = pkgs.stdenv.hostPlatform.system;
    athameZsh = athame-flake.defaultPackage.${system};
    insect = insect-flake.packages.${system}.default;
  in
{
  networking.hostName = "${hostName}";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Bluetooth + blueman service (needed for blueman-applet)
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.viktor = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  services.getty.autologinUser = "viktor";
  services.displayManager.autoLogin = {
    enable = true;
    user = "viktor";
  };

  systemd.settings.Manager.DefaultTimeoutStopSec = 30;
  #systemd.user.settings.Manager.DefaultTimeoutStopSec = 30;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      dmenu
      i3status
      i3lock
      i3blocks
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "viktor" ];
      KbdInteractiveAuthentication = false;
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
      X11Forwarding = true;
      X11UseLocalhost = true;
    };
  };
  users.users.viktor.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVqzZTQZj4xpYQeqah6QrXDqgvSBGYdDi3o7ahqzfOi82tN1u/3qsR61q9AEg26A6hPRiiZWl6x4UUInTob7P9qEqatUU5r6AWTu0ky/YYYU0348u1iK3RK1fVtr4/Qu9ZMuI9tRJHUYAoSu2QdAlq7BI79QaIdoqOPVlBnppSvaNdx73lWI2vsxQDY39DEkA1rSmhwNLwjYybTr9bHsVjUUJWy26xlrJ79rLhbMC/QEgSbnXOsG7zq2EI0Y//8PgHkTb6zVEqIDTZSRds1P2XA9oAFSwYPj1gMPt1iTgxoonMob1yRt+1P1ofhdNAy2Gl6GIUErS2H6pI3i+0O/D21s70hP9D+K9NILXXBsr36ssUauvNHeojkgKz6C5zXDvr1jRAeHdG8xxeje0s5Dr4+Q6xGPxhN8IFOjZJBtVHFMV0Dr4apOggpOG/uRTXhWBDQeUY4OYi94+lqeRQykno6ABZ8j2AITa1CXPz/DEuMwZuWwogq+lBfzv9snEqwCs= Null"
    ];
  environment.sessionVariables = {
    XAUTHORITY = "$HOME/.Xauthority";
  };
  security.sudo.extraConfig = ''
    Defaults env_keep += "DISPLAY XAUTHORITY"
  '';

  fonts.fontconfig.allowBitmaps = true;
  fonts.fontconfig.useEmbeddedBitmaps = true;
  fonts.fontconfig.enable = true;
  fonts.fontDir.enable = true;

  
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
  };
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # necessary for minimal WMs like i3
  xdg.portal.config.common.default = "*";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  services.pulseaudio.enable = true;
  services.pipewire.enable = false;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;


  home-manager.useUserPackages = true;
  home-manager.users.viktor = { pkgs, ... }: {
    #programs.bash.enable = true;
    # programs.zsh.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "26.05";
  };

  programs.firefox.enable = true;
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [{
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  }];
  
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  #
  environment.systemPackages = (with pkgs; [
    xauth
    wget
    gnumake
    xclip
    xsel
    git
    git-lfs
    git-filter-repo
    git-crypt
    openssl
    ranger
    xlsfonts
    htop-vim
    thunar
    pavucontrol
    octave
    xfce4-notifyd
    vesktop
    cava
    conky
    krita
    eog
    vimiv-qt
    zathura
    texliveFull
    mpv
    mpg123
    yt-dlp
    python3
    android-tools
    teams-for-linux
    docker
    wesnoth
    pdfpc
    ffmpeg-full
    inetutils
    arandr
    baobab
    shutter
    scrot
    imagemagick
    feh
    libnotify
    killall
    fatrace
    zip
    unzip
  ]) ++ [
    insect
    my-scripts-package
    klaxalk-scripts-package
    ];

  services.mullvad-vpn.enable = true;

   environment.etc."athamerc".source = "${athame-flake.inputs.athame}/athamerc";

   environment.shells = [ "${athameZsh}/bin/zsh" pkgs.bash ];
   users.users.viktor.shell = "${athameZsh}/bin/zsh";
   users.defaultUserShell = "${athameZsh}/bin/zsh";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}

