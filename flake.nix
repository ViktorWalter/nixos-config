{
  description = "V's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-old.url = "github:NixOS/nixpkgs/release-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    athame-flake = {
      url = "github:simonvpe/athame-flake";
      inputs.nixpkgs.follows = "nixpkgs-old";
    };

    #htop-vim = {
    #  url = "github:KoffeinFlummi/htop-vim";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};


  };

  outputs = { self, nixpkgs, nixpkgs-old, home-manager, athame-flake,  ... }:
    let
 	    system = "x86_64-linux";

      pkgsOld = import nixpkgs-old { inherit system; };

      #An overlay that adds `pkgs.athame-zsh` everywhere pkgs is used —
      # both in NixOS modules and (via useGlobalPkgs) in home-manager.
      athameOverlay = final: prev: {
        athame-zsh = final.callPackage ./pkgs/athame-zsh.nix { inherit athame-flake; pkgs=pkgsOld; };
      };


      mkHost = { hostName, system ? "x86_64-linux" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit hostName; inherit athame-flake; inherit pkgsOld; };
          modules = [
            { nixpkgs.overlays = [ athameOverlay ]; }
            ./configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit hostName athame-flake; }; 
              home-manager.users.viktor = import ./home.nix;
            }

            ({ pkgs, ... }: {
             systemd.tmpfiles.rules = [
             "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
             ];
             })
          ];
        };
      in {
        nixosConfigurations = {
          viktorPC = mkHost {hostName = "viktorPC"; };
      };
    };

      
}
