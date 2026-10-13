{
  description = "nixos-config — personal NixOS system (kelycube, kelymaster, slimbook, vm)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      inherit (inputs) nixpkgs home-manager;
      system = "x86_64-linux";
      specialArgs = inputs // { inherit inputs; };

      mkHost = hostModule:
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.genar = import ./home/genar.nix;
            }
            hostModule
          ];
        };

      vm = mkHost ./hosts/vm;
    in
    {
      nixosConfigurations.vm = vm;
      packages.${system} = {
        default = vm.config.system.build.vm;
      };
    };
}
