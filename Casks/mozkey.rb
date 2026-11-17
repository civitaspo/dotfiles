cask "mozkey" do
  version "1.1.0"
  sha256 "65fc763f6b1d20499030a1abef435ce87d397cee215b58e4d3d07961f3ef93cb"

  url "https://github.com/koyasi777/mozkey/releases/download/v#{version}/Mozkey_v#{version}_macos_universal.pkg"
  name "Mozkey"
  desc "Japanese input method based on Mozc"
  homepage "https://github.com/koyasi777/mozkey"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :monterey

  pkg "Mozkey_v#{version}_macos_universal.pkg", allow_untrusted: true

  uninstall pkgutil: "org.mozc.pkg.JapaneseInput"

  caveats <<~EOS
    Mozkey's installer is unsigned and unnotarized. Log out and back in,
    then enable Mozkey in System Settings > Keyboard > Text Input.
  EOS
end
