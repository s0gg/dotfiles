{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, emacs-overlay, flake-utils }: {
    packages."x86_64-darwin".default = let
      system = "x86_64-darwin";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ emacs-overlay.overlay ];
      };
    in pkgs.buildEnv {
      name = "home-packages";
      paths = with pkgs; [
        git
        bat
        eza
        fd
        ripgrep
        fzf
        fish
        delta
        gh
        ghq

        mu
        offlineimap
        msmtp
        emacs-git

        ruby_3_3
        deno
        go

        lua-language-server
      ];
    };
  };
}
