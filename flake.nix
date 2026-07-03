{
  description = "wataru.ichimura's macOS environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    let
      system = "aarch64-darwin";
      hostname = "MacBook-Pro-2";
      username = "wataru.ichimura";
      pkgs = nixpkgs.legacyPackages.${system};

      darwinRebuild = "${nix-darwin.packages.${system}.darwin-rebuild}/bin/darwin-rebuild";
      mkApp =
        name: command:
        {
          type = "app";
          program = toString (
            pkgs.writeShellScript "${name}-dotfiles" ''
              set -euo pipefail
              ${command}
            ''
          );
        };
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit
            inputs
            self
            hostname
            username
            ;
        };
        modules = [
          ./nix/hosts/MacBook-Pro-2.nix
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            home-manager = {
              extraSpecialArgs = {
                inherit username;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./nix/home;
            };

            nix-homebrew = {
              enable = true;
              user = username;
              autoMigrate = true;
              mutableTaps = true;
            };
          }
        ];
      };

      checks.${system}.darwin = self.darwinConfigurations.${hostname}.system;
      formatter.${system} = pkgs.nixfmt-rfc-style;

      apps.${system} = {
        build = mkApp "build" ''exec ${darwinRebuild} build --flake ".#${hostname}" "$@"'';
        switch = mkApp "switch" ''exec sudo ${darwinRebuild} switch --flake ".#${hostname}" "$@"'';
        update = mkApp "update" ''exec nix flake update "$@"'';
      };
    };
}
