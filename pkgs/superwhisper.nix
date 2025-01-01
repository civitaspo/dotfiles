{ lib, stdenv, fetchurl, _7zz }:

# NOTE: superwhisper only supports MacOS.
assert (stdenv.isDarwin);

stdenv.mkDerivation rec {
  pname = "superwhisper";
  version = "1.32.0";
  src = fetchurl {
    url = "https://builds.superwhisper.com/v${version}/superwhisper.dmg";
    sha256 = "6232b732e66a7a4f222b1b9415f50cac3c63f4e1b16f5a7e8569828ca8b3b20e";
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
    description = "AI powered voice to text for iOS and macOS";
    homepage = "https://superwhisper.com/";
    changelog = "https://superwhisper.canny.io/";
    license = licenses.unfree;
    platforms = platforms.darwin;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ civitaspo ]; # as a derivation maintainer
  };
}
