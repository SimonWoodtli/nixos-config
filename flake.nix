{
  description = "Personal NixOS/Home-Manager Configuration";

  inputs = {                                          # All flake references used to build my NixOS setup. These are dependencies.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11"; # Nix Packages
    #nurpkgs = {                                      # Nix User Packages
    #  url = github:nix-community/NUR;
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    home-manager = {                                  # Home Package Management
    Packages
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:     # Function that tells my flake which to use and what to do with dependencies.
    let                                               # Variables that can be used in the config files.
      system = "x86_64-linux";                        # System architecture
      user = "xnasero";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;                    # Allow proprietary software
      };
      lib = nixpkgs.lib;
    in {                                              # Use above variables in ...
      nixosConfigurations = {                         # Location of the available configurations 
        desktop = lib.nixosSystem {                   # Desktop profile
          inherit system user home-manager;           # Inherit variables to use here
          modules = [                                 # Modules that are used
            ./configuration.nix 
            home-manager.nixosModules.home-manager {  # Home-Manager module that is used
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${user} = {
                imports = [ ./home.nix ];
              };
          }
          ];
        };
      };
    };
}
