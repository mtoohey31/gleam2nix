{
  description = "gleam2nix";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    checks =
      # TODO: Generate tests for all supported Gleam platforms.
      nixpkgs.lib.genAttrs [ "x86_64-linux" ]
        (system:
          let
            pkgs = import nixpkgs {
              overlays = [ self.overlays.default ];
              inherit system;
            };
            gleam-test-package-roots = [
              "benchmark/list"
              # BROKEN: "compiler-cli/test/hello_world"
              "licence-bundler"
              "test/assert"
              # TODO: "test-community-packages"
              # BROKEN: "test/compile_package0"
              "test/erlang_shipment_no_dev_deps"
              "test/external_only_erlang"
              # UNSUPPORTED: "test/external_only_javascript"
              # BROKEN: "test/hello_world"
              "test/hextarball"
              "test/language"
              "test/multi_namespace"
              # UNSUPPORTED: "test/project_deno"
              # TODO: "test/project_erlang"
              "test/project_erlang_windows"
              # TODO: "test/project_git_deps"
              # UNSUPPORTED: "test/project_javascript"
              # TODO: "test/project_path_deps/project_a"
              "test/project_path_deps/project_b"
              "test/project_path_deps/project_c"
              "test/project_path_deps/project_d"
              "test/publishing_default_main"
              "test/publishing_default_readme"
              "test/publishing_empty_readme"
              "test/publishing_no_readme"
              "test/publishing_priv_symlink_escape"
              "test/publishing_src_symlink_escape"
              # BROKEN: "test/root_package_not_compiled_when_running_dep"
              "test/running_modules"
              # TODO: "test/subdir_ffi"
              # TODO: "test/unicode_path ⭐"
            ];
            inherit (pkgs) buildGleamProgram gleam;
          in
          nixpkgs.lib.genAttrs gleam-test-package-roots (package-root:
            buildGleamProgram {
              inherit (gleam) src;
              inherit package-root;
            }));

    overlays.default = import ./overlay.nix;

    templates.default = {
      description = "A simple Gleam project.";
      path = ./template;
    };
  };
}
