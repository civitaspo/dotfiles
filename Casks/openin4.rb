cask "openin4" do
  version "4.3.5-1"
  sha256 "64cde0c6d744ae80c8a0d44d87077970b91e6d9f920913d766d16756f558d23b"

  url "https://loshadki.app/openin4/releases/OpenIn-#{version}.app.zip"
  name "OpenIn 4"
  desc "Advanced link handler and browser picker"
  homepage "https://loshadki.app/openin4/"

  livecheck do
    url "https://loshadki.app/openin4/releases/appcast.xml"
    regex(/OpenIn[._-]v?(\d+(?:[.-]\d+)+)\.app\.zip/i)
    strategy :sparkle do |item, regex|
      item.url[regex, 1]
    end
  end

  auto_updates true

  app "OpenIn.app"

  zap trash: [
    "~/Library/Application Support/app.loshadki.OpenIn",
    "~/Library/Caches/app.loshadki.OpenIn",
    "~/Library/Preferences/app.loshadki.OpenIn.plist",
  ]
end
