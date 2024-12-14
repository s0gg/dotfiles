{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  username = "s0gg";
in {
  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      inputs.emacs-overlay.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
    packages = with pkgs; [
      gleam
      eza
      nmap
      gobuster
      neovim
      volta
      ghq
      cargo-binstall
      deno
      bun
      gh
      emacs
      fish
      zellij
      devenv
      hugo
      cmake
      libvterm
      libtool
      fd
      bat
      ripgrep
      fzf
      clojure
      go
      gopls
    ];
  };

  programs.home-manager.enable = true;
}
