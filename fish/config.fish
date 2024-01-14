if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_add_path $HOME/.nix-profile/bin
    fish_add_path /nix/var/nix/profiles/default/bin
    fish_add_path $HOME/.volta/bin
    fish_add_path /usr/local/opt/ruby/bin
    fish_add_path $HOME/.cargo/bin
    fish_add_path $HOME/.deno/bin
end
