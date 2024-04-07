{ inputs, config, lib, pkgs, ... }: {
  git.enable = true;
  git.attributes = [];
  git.delta.enable = true;
  git.extraConfig = {};
  git.hooks = {};
  git.ignores =[];
  git.includes = [
    # secret
    # {
    #   path = "~/.secret"
    # }
  ];
  git.signing.signByDefault = true;
  git.userEmail = "civitaspo@gmail.com";
  git.userName = "Takahiro Nakayama";
  git.extraConfig = {
    core.pager = "delta";
    core.autocrlf = "input";
    core.filemode = false;
    push.default = "simple";
    coler.ui = true;
    branch.autosetuprebase = "always";
    merge.ff = false;
    pull.rebase = "merges";
    # init.templatedir = "~/.git-template";
    init.defaultBranch = "main";
    interactive.diffFilter = "delta --color-only";
    diff.compactionHeuristic = true;
    fetch.recurseSubmodules = "yes";
    rebase.autoStash = true;
    delta.navigate = true;
    ghq.root = "~/src";
  };
}
