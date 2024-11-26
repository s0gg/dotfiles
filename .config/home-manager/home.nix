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
    ];
  };

  programs.home-manager.enable = true;
}
