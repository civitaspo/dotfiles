{ ... }:

let
  filesDir = ../files;
in
  with builtins;
  foldl' (acc: path: acc // ({
      "${path}" = {
        source = filesDir + ("/" + path);
        recursive = true;
      };
    } ))
    { }
    (filter (n: (match ".*" n) != null)
      (attrNames (readDir filesDir)))
