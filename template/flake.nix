{
  description = "CHANGEME";

  inputs = {
    nixpkgs.follows = "gleam2nix/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    gleam2nix.url = "github:mtoohey31/gleam2nix";
  };

  outputs = { self, nixpkgs, flake-utils, gleam2nix }: {
    overlays = rec {
      expects-gleam2nix = final: _: {
        CHANGEME = final.buildGleamProgram {
          src = builtins.path { path = ./.; name = "CHANGEME-src"; };
        };
      };
      default = nixpkgs.lib.composeManyExtensions [
        gleam2nix.overlays.default
        expects-gleam2nix
      ];
    };
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        overlays = [ self.overlays.default ];
        inherit system;
      };
      inherit (pkgs) CHANGEME mkShell;
    in
    {
      packages.default = CHANGEME;

      devShells.default = mkShell {
        inputsFrom = [ CHANGEME ];
      };
    });
}
