cask "kanary" do
  version "2.4.2"
  sha256 "67b5c75361e4941b85c86311bc00a28773a498eb9858e6fedd12fa830b054b07"

  url "https://cdn.kanary.download/releases/Kanary-#{version}.zip",
      verified: "cdn.kanary.download/releases/"
  name "Kanary"
  desc "Menu bar app for on-device meeting recording and keyboard remapping"
  homepage "https://kanary.download/"

  livecheck do
    url "https://cdn.kanary.download/appcast.xml"
    strategy :sparkle, &:short_version
  end

  auto_updates true
  depends_on macos: :sonoma
  depends_on arch: :arm64

  app "Kanary.app"

  zap trash: [
    "~/Library/Application Support/download.kanary",
    "~/Library/Caches/download.kanary",
    "~/Library/HTTPStorages/download.kanary",
    "~/Library/Preferences/download.kanary.plist",
    "~/Library/Saved Application State/download.kanary.savedState",
  ]
end
