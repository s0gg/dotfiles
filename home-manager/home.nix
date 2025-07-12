{ lib, config, pkgs, ... }:

let
  gcloud = pkgs.google-cloud-sdk.withExtraComponents [
    pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
    pkgs.google-cloud-sdk.components.kubectl
  ];
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "s0gg";
  home.homeDirectory = "/home/s0gg";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    # (pkgs.buildGoModule {
    #   pname = "iccheck";
    #   version = "0.9.0";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "salab";
    #     repo = "iccheck";
    #     rev = "v0.9.0";
    #     sha256 = "sha256-2bD5gN/7C79njrCVoR5H2ses6pWAQHZcYj7/f2+Ui/o=";
    #   };
    #   vendorHash = "sha256-pqjtoshoQlz+SFpaaxN3GMaDdZ+ztiIV6w+CTrRHuaA=";
    #   meta = with lib; {
    #     homepage = "https://github.com/salab/iccheck";
    #   };
    #   doCheck = false;
    #   subPackages = [
    #     "."
    #     "./cmd"
    #     "./pkg/domain"
    #     "./pkg/fleccs"
    #     "./pkg/lsp"
    #     "./pkg/ncdsearch"
    #     "./pkg/printer"
    #     "./pkg/search"
    #     "./pkg/utils"
    #   ];
    # })
    gcloud
    pkgs.awscli2
    pkgs.bat
    pkgs.clojure-lsp
    pkgs.cobra-cli
    pkgs.dig
    pkgs.direnv
    pkgs.eza
    pkgs.fd
    pkgs.fzf
    pkgs.gh
    pkgs.ghq
    pkgs.git
    pkgs.go
    pkgs.gopls
    pkgs.httpx
    pkgs.k9s
    pkgs.lua-language-server
    pkgs.minikube
    pkgs.ripgrep
    pkgs.subfinder
    pkgs.tmux
    pkgs.uv
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/s0gg/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs = {
    home-manager = {
      enable = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -x NIX_PATH $HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels
        if test -n "$NIX_PATH"
            set -x NIX_PATH $NIX_PATH:$NIX_PATH
        end
        source "$HOME/.cargo/env.fish"
        set -gx VOLTA_HOME "$HOME/.volta"
        set -gx PATH "$VOLTA_HOME/bin" $PATH
        set -gx GHQ_ROOT "$HOME/.local/ghq"
        fish_add_path "$HOME/.local/bin"
        fish_add_path "/usr/local/go/bin"
        fish_add_path "$HOME/go/bin"
        eval (direnv hook fish)
        set -gx MANPAGER "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
        # Commands to run in interactive sessions can go here
        abbr mrl 'cd "$GHQ_ROOT/$(ghq list | fzf)"'
        abbr ll 'eza --icons -lahF'
      '';
    };

    emacs = {
      enable = true;
      package = pkgs.emacs;
    };

    neovim = {
      enable = true;
      package = pkgs.neovim;
    };
  };
}
