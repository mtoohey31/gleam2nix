# gleam2nix

gleam2nix provides an overlay for building Gleam projects.

## Usage

If you're using flakes, start by adding `gleam2nix.overlays.default` to your nixpkgs overlays. If you're not using flakes, you can import the overlay directly from the `overlay.nix` file. This overlay defines the `buildGleamProgram` helper, which can be used to export an Erlang shipment from your Gleam project, and create a wrapper script to its entrypoint in the output `bin` directory. The only required parameter is `src`, which should usually be a path to the root of your Gleam project, the directory containing the `gleam.toml` and `manifest.toml` files (though `project-root` may be useful if you have multiple related packages within your source). Package name and version are inferred from the `gleam.toml` file. There are three optional parameters:
- `bin-name` can be used to rename the binary wrapper added to the output path's `bin` directory. If not provided, it defaults to the package name inferred from `gleam.toml`.
- `project-root` can be used when the package you want to build isn't located at the root of `src` (but you can't just adjust `src` to be the subdirectory since your main package depends on local packages located elsewhere inside `src`). Defaults to `.` (the root of `src`).
- `doCheck` indicates whether `gleam test` should be run during the derivation's `checkPhase`. If not provided, it is set iff `src + "/${project-root}$/test"` exists.
