cask "circleback" do
  arch arm: "arm64", intel: "x64"

  version "2.9.6,260526zpmm57tu0"
  sha256 :no_check

  url "https://download.todesktop.com/2603165j5j84b/Circleback%20#{version.csv.first}%20-%20Build%20#{version.csv.second}-#{arch}-mac.zip",
      verified: "download.todesktop.com/2603165j5j84b/"
  name "Circleback"
  desc "AI meeting recorder and note taker"
  homepage "https://circleback.ai/desktop"

  auto_updates true
  depends_on macos: ">= :big_sur"

  app "Circleback.app"

  zap trash: [
    "~/Library/Application Support/Circleback",
    "~/Library/Caches/com.todesktop.*",
    "~/Library/Caches/com.todesktop.*.ShipIt",
    "~/Library/HTTPStorages/com.todesktop.*",
    "~/Library/Logs/Circleback",
    "~/Library/Preferences/com.todesktop.*.plist",
    "~/Library/Saved Application State/com.todesktop.*.savedState",
    "~/Library/Saved Application State/todesktop.com.ToDesktop-Installer.savedState",
  ]
end
