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
      branches = {
        setUpstream = "U";
      };
      commits = {
        moveDownCommit = "D";
        moveUpCommit = "U";
      };
      files = {
        findBaseCommitForFixup = "";
        openStatusFilter = "";
      };
    };
    customCommands = [
      {
        key = "u";
        context = "global";
        command = "git pull origin main --rebase";
        description = "Pull main branch & rebase current branch";
        loadingText = "Pulling main branch & rebasing current branch...";
        output = "log";
        prompts = [
          {
            type = "confirm";
            title = "Pull main branch & rebase current branch";
            body = "Are you sure you want to pull main branch & rebase current branch?";
          }
        ];
        after = {
          checkForConflicts = true;
        };
      }
      {
        key = "<c-d>";
        context = "localBranches";
        command = "git fetch --prune && git for-each-ref --format '%(refname:short) %(upstream:track)' | grep '\\[gone\\]$' | cut -d' ' -f1 | xargs -I%% git branch -D %%";
        description = "Delete local branches that are gone";
        loadingText = "Deleting local branches that are gone...";
        output = "log";
        prompts = [
          {
            type = "confirm";
            title = "Delete local branches that are gone";
            body = "Are you sure you want to delete local branches that are gone?";
          }
        ];
        after = {
          checkForConflicts = true;
        };
      }
      # {
      #   key = "<c-y>";
      #   context = "localBranches";
      #   description = "Create a New Pull Request";
      #   command = "gh pr create --base {{.SelectedLocalBranch.Name}}";
      #   prompts = [
      #     {
      #       type = "menu";
      #       title = "Semantic PR Type";
      #       key = "SemPRType";
      #       options = [
      #         {
      #           name = "feat";
      #           description = "A new feature";
      #           value = "feat";
      #         }
      #         {
      #           name = "fix";
      #           description = "A bug fix";
      #           value = "fix";
      #         }
      #         {
      #           name = "chore";
      #           description = "Other changes that don't modify src or test files";
      #           value = "chore";
      #         }
      #         {
      #           name = "ci";
      #           description = "Changes to CI configuration files and scripts";
      #           value = "ci";
      #         }
      #         {
      #           name = "docs";
      #           description = "Documentation only changes";
      #           value = "docs";
      #         }
      #         {
      #           name = "deps";
      #           description = "Update dependencies";
      #           value = "deps";
      #         }
      #         {
      #           name = "perf";
      #           description = "A code change that improves performance";
      #           value = "perf";
      #         }
      #         {
      #           name = "refactor";
      #           description = "A code change that neither fixes a bug nor adds a feature";
      #           value = "refactor";
      #         }
      #         {
      #           name = "revert";
      #           description = "Reverts a previous commit";
      #           value = "revert";
      #         }
      #         {
      #           name = "style";
      #           description = "Changes that do not affect the meaning of the code";
      #           value = "style";
      #         }
      #         {
      #           name = "test";
      #           description = "Adding missing tests or correcting existing tests";
      #           value = "test";
      #         }
      #       ];
      #     }
      #     {
      #       type = "input";
      #       title = "PR Title";
      #       key = "title";
      #       placeholder = "Enter PR title";
      #     }
      #   ];
      # }
    ];
  };
}
