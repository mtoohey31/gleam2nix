{
  description = "gleam2nix";

  # NOTE: We don't actually use this directly (though we might once there are
  # tests) but it's here to act as an indicator of what we're compatible with.
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  outputs = _: {
    # TODO: Add tests.
    overlays.default = import ./overlay.nix;
  };
}
