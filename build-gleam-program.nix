{ elixir
, erlang
, fetchHex
, formats
, gleam
, lib
, linkFarm
, makeWrapper
, rebar3
, stdenv
}:
let readTOML = path: builtins.fromTOML (builtins.readFile path); in
{ src
, package-root ? "."
, bin-name ? (readTOML (src + "/${package-root}/gleam.toml")).name
, doCheck ? builtins.pathExists (src + "/${package-root}/test")
}:

let
  gleam-toml = readTOML (src + "/${package-root}/gleam.toml");
  manifest-toml = readTOML (src + "/${package-root}/manifest.toml");

  link-farm-package-entries = map
    ({ name, version ? "0.1.0", source, ... }@package:
      if source == "hex" then
        let
          path = fetchHex {
            pkg = name;
            inherit version;
            sha256 = package.outer_checksum;
          };
        in
        { inherit name path; }
      else if source == "local" then
        { inherit name; path = src + "/${package-root}/${package.path}"; }
      else throw "gleam2nix: unsupported dependency source: ${source}"
    )
    manifest-toml.packages;

  inherit (gleam-toml) name;
  version = gleam-toml.version or "0.1.0";
  packages-name = "${name}-${version}-packages";

  packages-toml.packages = builtins.listToAttrs
    (map ({ name, version, ... }: { inherit name; value = version; })
      manifest-toml.packages);
  packages-toml-file = (formats.toml { }).generate "${packages-name}.toml"
    packages-toml;

  link-farm-entries = link-farm-package-entries ++ [{
    name = "packages.toml";
    path = packages-toml-file;
  }];
  build-packages = linkFarm packages-name link-farm-entries;

  all-build-tools = lib.flatten (map (p: p.build_tools) manifest-toml.packages);
in
stdenv.mkDerivation {
  pname = name;
  inherit version src;
  nativeBuildInputs = [ erlang gleam makeWrapper ] ++
    lib.optional (builtins.elem "mix" all-build-tools) elixir ++
    lib.optional
      (builtins.elem "rebar" all-build-tools ||
        builtins.elem "rebar3" all-build-tools)
      rebar3;
  configurePhase = ''
    runHook preConfigure

    cd ${package-root}
    rm -rf build
    mkdir build
    cp -r --no-preserve=mode --dereference ${build-packages} build/packages

    runHook postConfigure
  '';
  buildPhase = ''
    runHook preBuild

    gleam export erlang-shipment

    runHook postBuild
  '';
  inherit doCheck;
  checkPhase = ''
    runHook preCheck

    gleam test

    runHook postCheck
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/gleam}
    cp -r build/erlang-shipment $out/share/gleam/${name}
    makeWrapper $out/share/gleam/${name}/entrypoint.sh \
      $out/bin/${bin-name} --add-flags run \
      --prefix PATH : ${erlang}/bin

    runHook postInstall
  '';
}
