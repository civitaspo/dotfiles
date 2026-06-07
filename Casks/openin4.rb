cask "openin4" do
  version "4.3.5-1"
  sha256 "64cde0c6d744ae80c8a0d44d87077970b91e6d9f920913d766d16756f558d23b"

  url "https://loshadki.app/openin4/releases/OpenIn-#{version}.app.zip"
  name "OpenIn 4"
  desc "Advanced link handler and browser picker"
  homepage "https://loshadki.app/openin4/"

  app "OpenIn.app"

  zap trash: [
    "~/Library/Application Support/app.loshadki.OpenIn",
    "~/Library/Caches/app.loshadki.OpenIn",
    "~/Library/Preferences/app.loshadki.OpenIn.plist",
  ]
end
