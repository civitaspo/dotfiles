{ ... }:

let
  xdgDir = ../xdg;
in
  with builtins;
  foldl' (acc: path: acc // (
    {
      configFile = (acc.configFile //
        {
          ${path} = {
            source = xdgDir + ("/" + path);
            recursive = true;
          };
        }
      );
    }))
    { enable = true; configFile = {}; }
    (filter (n: (match ".*" n) != null)
      (attrNames (readDir xdgDir)))
