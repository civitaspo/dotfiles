{ inputs, config, lib, pkgs, ... }:

{
  gh-dash.enable = true;
  gh-dash.settings = {
    prSections = [
      {
        title = "My Pull Requests";
        filters = "is:open author:@me";
      }
    ];
  };
}
