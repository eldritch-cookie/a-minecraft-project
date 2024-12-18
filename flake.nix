{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks-nix.flakeModule
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        treefmt.programs = {
        };
        treefmt.projectRootFile = "flake.nix";
        pre-commit.settings.hooks = {
          treefmt.enable = true;
          typos.enable = true;
        };
        packages.default = pkgs.prismlauncher.override {
          prismlauncher-unwrapped = pkgs.prismlauncher-unwrapped.overrideAttrs (prevAttrs: {
            patches = [./cracked.patch ./accounts.patch];
          });
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}
