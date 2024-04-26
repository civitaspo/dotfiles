{ lib, stdenv, fetchurl, _7zz }:

# NOTE: superkey only supports MacOS.
assert (!stdenv.isLinux);

stdenv.mkDerivation rec {
  pname = "superkey";
  version = "1.33";
  src = fetchurl {
    url = "https://superkey.app/downloads/Superkey${version}.dmg"
    # nix hash path /path/to/Superkey${version}.dmg
    hash = "sha256-mEQwjb/z+1KjvfmUov+x9Bdc/tZ+8ithZ2Ige0HVl7c=";
  };
  nativeBuildInputs = [ _7zz ];
  sourceRoot = ".";
  # NOTE: We use _7zz instead of undmg, because of avoiding the following error.
  #       > @nix { "action": "setPhase", "phase": "unpackPhase" }
  #       > Running phase: unpackPhase
  #       > unpacking source archive /nix/store/0f0a0jvmjqcqyblfjy589chnc8v2qagm-superkey.dmg
  #       > error: only HFS file systems are supported.
  #       > do not know how to unpack source archive /nix/store/0f0a0jvmjqcqyblfjy589chnc8v2qagm-superkey.dmg
  # NOTE: 'unpackCmd' will be removed after the following PR is merged.
  #       ref. https://github.com/NixOS/nixpkgs/pull/289900
  unpackCmd = ''
    7zz x $curSrc
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple and powerful keyboard enhancement on macOS";
    homepage = "https://superkey.app/";
    changelog = "https://superkey.app/";
    license = licenses.unfree;
    platforms = platforms.darwin;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ civitaspo ]; # as a derivation maintainer
  };
}
