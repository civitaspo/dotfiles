{ lib, stdenv, fetchurl }:

# NOTE: aqua supports Linux, MacOS, and Windows. But this derivation only supports MacOS.
assert (stdenv.isDarwin);

stdenv.mkDerivation rec {
  pname = "superwhisper";
  version = "2.41.0";
  src = fetchurl {
    url = "https://github.com/aquaproj/aqua/releases/download/v${version}/aqua_darwin_arm64.tar.gz";
    sha256 = "3c6750cfc8e28d65c008c819ac8fc0b2f23c6aba7e9eaacbe5e7eed0b68903cd";
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
