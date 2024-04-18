# gleam2nix

gleam2nix provides an overlay for building Gleam projects.

## Usage

If you're using flakes, start by adding `gleam2nix.overlays.default` to your nixpkgs overlays. If you're not using flakes, you can import the overlay directly from the `overlay.nix` file. This overlay defines the `buildGleamProgram` helper, which can be used to build a Gleam binary. The only required parameter is `src`, which should be a path to the root of your Gleam project (the directory containing the `gleam.toml` and `manifest.toml` files). Package name and version are inferred from the `gleam.toml` file. There are two optional parameters:
- `bin-name` can be used to rename the binary wrapper added to the output path's `bin` directory. If not provided, it defaults to the package name inferred from `gleam.toml`.
- `doCheck` indicates whether `gleam test` should be run during the derivation's `checkPhase`. If not provided, it defaults to `true`.
