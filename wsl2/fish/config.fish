fish_add_path $HOME/.local/bin
set -gx BUN_INSTALL $HOME/.bun
fish_add_path $BUN_INSTALL/bin
set -gx VOLTA_HOME $HOME/.volta
fish_add_path $VOLTA_HOME/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.deno/bin
set -gx GHQ_ROOT $HOME/dev

if status is-interactive
    set -gx EDITOR nvim
    # Commands to run in interactive sessions can go here
    abbr -a co "gh pr list --assignee @me | fzf | cut -f 1 | xargs -I {} gh pr checkout {}"
    abbr -a g git
    abbr -a gsw "git branch | fzf | tr -d \\[:blank:\\] | xargs -I {} git switch {}"
    abbr -a mypr "gh pr list --assignee @me"
    abbr -a pull git pull
    abbr -a st git status
end
