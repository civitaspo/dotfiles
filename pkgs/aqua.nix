{ lib, stdenv, fetchurl }:

# NOTE: aqua supports Linux, MacOS, and Windows. But this derivation only supports MacOS.
assert (stdenv.isDarwin);

stdenv.mkDerivation rec {
  pname = "superwhisper";
  version = "2.43.0";
  src = fetchurl {
    url = "https://github.com/aquaproj/aqua/releases/download/v${version}/aqua_darwin_arm64.tar.gz";
    sha256 = "ec1b13cd972cd9f2d58acf6c544c082de0e448c0aa343310c303b6f0b0daff8d";
  };
  sourceRoot = ".";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r aqua $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "Declarative CLI Version Manager written in Go.";
    homepage = "https://aquaproj.github.io/";
    changelog = "https://github.com/aquaproj/aqua/releases";
    license = licenses.mit;
    platforms = platforms.darwin;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ civitaspo ]; # as a derivation maintainer
  };
}
