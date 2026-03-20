{ stdenv, lib }:

let
  buildMeta = builtins.fromJSON (builtins.readFile ../../build-meta/sglang-flox-runtime.json);
  buildVersion = buildMeta.build_version;
  version = "0.5.9";
in

stdenv.mkDerivation {
  pname = "sglang-flox-runtime";
  inherit version;

  src = ../../scripts;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    for script in sglang-resolve-model sglang-serve; do
      install -m 0755 "$script" "$out/bin/$script"
    done

    mkdir -p $out/share/sglang-flox-runtime
    cat > $out/share/sglang-flox-runtime/flox-build-version-${toString buildVersion} <<'MARKER'
    build-version: ${toString buildVersion}
    upstream-version: ${version}
    git-rev: ${buildMeta.git_rev}
    git-rev-short: ${buildMeta.git_rev_short}
    MARKER
  '';

  meta = with lib; {
    description = "Runtime scripts for SGLang model serving with Flox";
    platforms = [ "x86_64-linux" ];
  };
}
