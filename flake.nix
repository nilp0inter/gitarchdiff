{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };

  description = "Find differences between a source distribution and a git repository";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {
        homeManagerModules.default = ./home-module.nix;
      };
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];

      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {
        self',
        config,
        pkgs,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cargo
            rustc
            rustfmt
            clippy
            openssl
            pkg-config
          ];
        };

        overlayAttrs = {
          inherit (config.packages) gitarchdiff;
        };

        packages.gitarchdiff = pkgs.rustPlatform.buildRustPackage {
          pname = "gitarchdiff";
          version = "0.1.0";

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          meta = with nixpkgs.lib; {
            description = "Find differences between a source distribution and a git repository";
            homepage = "https://github.com/nilp0inter/gitarchdiff";
            license = licenses.mit;
            platforms = platforms.linux;
            maintainers = with maintainers; [nilp0inter];
            mainProgram = "gitarchdiff";
          };
        };

        packages.default = self'.packages.gitarchdiff;

        formatter = pkgs.alejandra;
      };
    };
}
