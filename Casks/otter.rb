cask "otter" do
  version :latest
  sha256 :no_check

  url "https://assets.otter.ai/desktop-app/mac/production/otter_universal_latest.dmg",
      verified: "assets.otter.ai/desktop-app/mac/production/"
  name "Otter"
  desc "AI meeting transcription and notes"
  homepage "https://otter.ai/"

  auto_updates true
  depends_on macos: ">= :monterey"

  app "Otter.app"

  zap trash: [
    "~/Library/Application Support/Otter",
    "~/Library/Caches/ai.otter.desktop",
    "~/Library/HTTPStorages/ai.otter.desktop",
    "~/Library/Logs/Otter",
    "~/Library/Preferences/ai.otter.desktop.plist",
    "~/Library/Saved Application State/ai.otter.desktop.savedState",
  ]
end
