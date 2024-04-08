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

  git.signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlmYWLNT2IyKC0InCp3Upis6d3pH25NcQaPuDntjSWJ";
  git.signing.signByDefault = true;
  git.userEmail = "civitaspo@gmail.com";
  git.userName = "Takahiro Nakayama";
  git.extraConfig = {
    core.pager = "${pkgs.delta}/bin/delta";
    core.autocrlf = "input";
    core.filemode = false;
    push.default = "simple";
    coler.ui = true;
    branch.autosetuprebase = "always";
    gpg.format = "ssh";
    # TODO: Set another tool when isDarwin != true.
    gpg.ssh.program = "${pkgs._1password}/Contents/MacOS/op-ssh-sign";
    merge.ff = false;
    pull.rebase = "merges";
    # init.templatedir = "~/.git-template";
    init.defaultBranch = "main";
    interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
    diff.compactionHeuristic = true;
    fetch.recurseSubmodules = "yes";
    rebase.autoStash = true;
    delta.navigate = true;
    ghq.root = "~/src";
  };
}
