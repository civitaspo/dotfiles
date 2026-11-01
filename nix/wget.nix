{ lib, wget, fetchurl }:

# Backport upstream fixes until a patched wget release is available.
wget.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ lib.optionals (lib.versionOlder wget.version "1.25.1") (lib.filter
    (patch: !lib.any (existing: lib.hasInfix (lib.toLower (lib.removeSuffix ".patch" patch.name)) (lib.toLower (toString existing))) (old.patches or [ ]))
    [
    (fetchurl {
      name = "CVE-2026-58471.patch";
      url = "https://github.com/mirror/wget/commit/c2640fe5171c59f87c58dc9fcb195b2d18b010ee.patch";
      hash = "sha256-RcDh6AH7P7AUZ2fUDcK6x3uB4ZTJL6LqSEhyt98OOQ4=";
    })
    (fetchurl {
      name = "CVE-2026-58470.patch";
      url = "https://github.com/mirror/wget/commit/43d3ba9336bc94937e6fae2365c6ffd30c34ffcf.patch";
      hash = "sha256-c5O0ebz/q+HZppcah2A7U5zr2TvZzKR7WbtI2o+H4XA=";
    })
    (fetchurl {
      name = "CVE-2026-58469.patch";
      url = "https://github.com/mirror/wget/commit/37a40fcb450153f69537c7cbc2a7a4fb0b6f7826.patch";
      hash = "sha256-dTBZO5t3FEhxZ8J0M5K72Erfz8zivhBlZ/Ft2VavDZY=";
    })
    (fetchurl {
      name = "CVE-2026-58472.patch";
      url = "https://github.com/mirror/wget/commit/dd692d9cea5335b181d877ae917fe6e75587a812.patch";
      hash = "sha256-kYr6OPyYF42t/Pq2ZVPxGLfr9qwZ0mz5+m5Vw68wiTs=";
    })
    (fetchurl {
      name = "CVE-2026-15146.patch";
      url = "https://github.com/mirror/wget/commit/4f85853f641863d5915786a8413e1a213726a62b.patch";
      hash = "sha256-rCkzxUOxBwAIQSQbjsOiWHZoc/dxZwCfOZ3Z9rUqgbE=";
    })
    (fetchurl {
      name = "CVE-2026-16599.patch";
      url = "https://github.com/mirror/wget/commit/e9697d98e7249b0f68a6be040a4f3dcc5bc101fa.patch";
      hash = "sha256-G0kniB32HpXbRDTNxKE2qmruC6ZXZheXW1Le20ZDMuA=";
    })
    ]);
})
