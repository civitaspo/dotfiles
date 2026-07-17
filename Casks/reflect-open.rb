cask "reflect-open" do
  arch arm: "aarch64", intel: "x86_64"

  version "0.6.1-beta.2"
  sha256 arm:   "a24c0a3a22f003f96e2647212ff42df68934c01522ba4f497bf3e71c8eb923ba",
         intel: "b69b15cb90a69d84e9c71b798842c84ca307334710189a163c82fbe546e66ce4"

  url "https://github.com/team-reflect/reflect-open/releases/download/v#{version}/Reflect.Beta_#{arch}.dmg",
      verified: "github.com/team-reflect/reflect-open/"
  name "Reflect Open"
  desc "Open-source rewrite of the Reflect notes app (beta channel)"
  homepage "https://github.com/team-reflect/reflect-open"

  livecheck do
    url "https://github.com/team-reflect/reflect-open/releases/download/updater-beta/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  auto_updates true
  depends_on macos: :monterey

  app "Reflect Beta.app"

  zap trash: [
    "~/Library/Application Support/app.reflect.desktop.beta",
    "~/Library/Caches/app.reflect.desktop.beta",
    "~/Library/Preferences/app.reflect.desktop.beta.plist",
    "~/Library/Saved Application State/app.reflect.desktop.beta.savedState",
    "~/Library/WebKit/app.reflect.desktop.beta",
  ]
end
