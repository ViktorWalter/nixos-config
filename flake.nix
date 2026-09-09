{
  description = "V's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # nixpkgs-old.url = "github:NixOS/nixpkgs/release-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    athame-flake = {
      url = "github:simonvpe/athame-flake";
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/2deb07f3ac4eeb5de1c12c4ba2911a2eb1f6ed61";
      #with this specific nixpkgs it should resolve to the same commit the author used, but in a more reliable way than without it.
      #my machine tended to override it such that athame was built with zsh 5.9, rather than the more reliably compatible 5.8.
      #the reason is that the author locked it using local nixpkgs channel that is not available to me, so NixOS just defaults to my own.
    };

    insect-flake = {
      url = "github:ViktorWalter/insect-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    my-scripts-repo = {
      url = "github:ViktorWalter/scripts_and_utils";
      flake = false;
    };
    
    klaxalk-scripts-repo = {
      url = "github:klaxalk/linux-setup";
      flake = false;
    };

  };

  outputs = { self, nixpkgs, home-manager, athame-flake, insect-flake, nix-flatpak, my-scripts-repo, klaxalk-scripts-repo, ... }:
    let
 	    system = "x86_64-linux";

      my-scripts-package = nixpkgs.legacyPackages.${system}.runCommand "my-scripts" {} ''
        mkdir -p $out/bin

        find ${my-scripts-repo}/scripts -type f -executable \
          -exec sh -c '
            for script do
              ln -s "$script" "$out/bin/$(basename "$script")"
            done
          ' _ {} +
      '';
      klaxalk-scripts-package = nixpkgs.legacyPackages.${system}.runCommand "klaxalk-scripts" {} ''
        mkdir -p $out/bin

        find ${klaxalk-scripts-repo}/scripts -type f -executable \
          -exec sh -c '
            for script do
              ln -s "$script" "$out/bin/$(basename "$script")"
            done
          ' _ {} +
          # basic MRS shell additions too
          ln -s ${klaxalk-scripts-repo}/appconfig/shell/commons.sh_git \
          $out/bin/mrs_commons.sh
      '';

      mkHost = { hostName, system ? "x86_64-linux" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit hostName athame-flake insect-flake nix-flatpak my-scripts-package klaxalk-scripts-package; };
          modules = [
            # { nixpkgs.overlays = [ athameOverlay ]; }
            nix-flatpak.nixosModules.nix-flatpak
            ./configuration.nix #generic
            ./hosts/${hostName}/configuration.nix #specific

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit hostName athame-flake self; }; 
              home-manager.users.viktor = import ./home.nix;
            }

            ({ pkgs, ... }: {
             systemd.tmpfiles.rules = [
             "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
             "L+ /usr/bin/perl - - - - ${(pkgs.perl.withPackages (ps: [ ps.Git ]))}/bin/perl"
             ];
             })

          ];
        };
      in {
        nixosConfigurations = {
          viktorPC = mkHost {hostName = "viktorPC"; };
          viktorGPD = mkHost {hostName = "viktorGPD"; };
      };
    };

      
}
