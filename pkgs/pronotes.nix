{ lib, stdenv, fetchurl, _7zz }:

# NOTE: pronotes only supports MacOS.
assert (stdenv.isDarwin);

stdenv.mkDerivation rec {
  pname = "ProNotes";
  version = "0.4";
  src = fetchurl {
    url = "https://pronotes.app/direct-download";
    sha256 = "sha256-TRc882EcufR/5dznmY2KMcGzpWvJMMQvxy6v1Zym0xw=";
  };
  nativeBuildInputs = [ _7zz ];
  sourceRoot = ".";
  # NOTE: We use _7zz instead of undmg, because of avoiding the following error.
  #       > @nix { "action": "setPhase", "phase": "unpackPhase" }
  #       > Running phase: unpackPhase
  #       > unpacking source archive /nix/store/0f0a0jvmjqcqyblfjy589chnc8v2qagm-superwhisper.dmg
  #       > error: only HFS file systems are supported.
  #       > do not know how to unpack source archive /nix/store/0f0a0jvmjqcqyblfjy589chnc8v2qagm-superwhisper.dmg
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
    description = "ProNotes is an Apple Notes extension that makes your favourite note-taking app even more enjoyable to use.";
    homepage = "https://www.pronotes.app/";
    changelog = "https://www.pronotes.app/";
    license = licenses.unfree;
    platforms = platforms.darwin;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ civitaspo ]; # as a derivation maintainer
  };
}
