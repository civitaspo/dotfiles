{ inputs, config, lib, pkgs, ... }:

{
  lazygit.enable = true;
  lazygit.settings = {
    # https://github.com/jesseduffield/lazygit/blob/145fb6191c108f7e7af8180106b82f0503a7994c/docs/Config.md
    git = {
      overrideGpg = true;
      paging = {
        colorArg = "always";
        pager = "${pkgs.delta}/bin/delta --paging=never";
      };
      commit = {
        signOff = true;
      };
    };
    keybinding = {
      universal = {
        prevItem = "<c-p>";
        nextItem = "<c-n>";
        prevBlock = "<c-b>";
        nextBlock = "<c-f>";
        gotoTop = "<c-t>";
        gotoBottom = "G";
        pushFiles = "P";
        pullFiles = "p";
        createPatchOptionsMenu = "<c-x>";
        diffingMenu-alt = "";
      };
      files = {
        findBaseCommitForFixup = "";
        openStatusFilter = "";
      };
    };
  };
}
