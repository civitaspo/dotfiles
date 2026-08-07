cask "nospace" do
  version "0.1.7"
  sha256 "14f4012a6da34fae84ab90753143e06cd9cdec3290f9829265a21354c60cafb5"

  url "https://github.com/ryotarai/nospace-public/releases/download/v#{version}/Nospace-#{version}.zip",
      verified: "github.com/ryotarai/nospace-public/"
  name "Nospace"
  desc "Menu bar app for AI Japanese conversion without space-key henkan"
  homepage "https://nospace.ryotarai.dev/"

  livecheck do
    url "https://nospace.ryotarai.dev/appcast.xml"
    strategy :sparkle, &:short_version
  end

  auto_updates true
  depends_on macos: :sonoma
  depends_on arch: :arm64

  app "Nospace.app"

  zap trash: [
    "~/Library/Application Support/dev.ryotarai.nospace",
    "~/Library/Caches/dev.ryotarai.nospace",
    "~/Library/HTTPStorages/dev.ryotarai.nospace",
    "~/Library/Preferences/dev.ryotarai.nospace.plist",
    "~/Library/Saved Application State/dev.ryotarai.nospace.savedState",
  ]
end
