{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, neovim-nightly-overlay }: {

    packages.x86_64-linux.my-packages = nixpkgs.legacyPackages.x86_64-linux.buildEnv {
      name = "my-package-list";
      paths = [
        nixpkgs.legacyPackages.x86_64-linux.gleam
        nixpkgs.legacyPackages.x86_64-linux.eza

        nixpkgs.legacyPackages.x86_64-linux.nmap
        nixpkgs.legacyPackages.x86_64-linux.gobuster
        neovim-nightly-overlay.packages.x86_64-linux.neovim
      ];
    };

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
