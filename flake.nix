{
  description = "Lean Development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    lean.url = "github:leanprover/lean4";
    flake-utils.url = "github:numtide/flake-utils";
    shell-utils.url = "github:waltermoreira/shell-utils";
    myvscode.url = "github:waltermoreira/myvscode";
  };

  outputs = { self, nixpkgs, lean, flake-utils, shell-utils, myvscode }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        vscode-lean4 = pkgs.vscode-utils.extensionFromVscodeMarketplace {
          name = "lean4";
          publisher = "leanprover";
          version = "0.0.103";
          sha256 = "sha256-3hpvln4IW53ApMm2PFr2v8Gd5ZdSSzc0cAz1hvS6jWU=";
        };
        vscode = myvscode.makeMyVSCode pkgs {
          extraExtensions = [
            vscode-lean4
          ];
          extraSettings = {
            "lean4.toolchainPath" = "${pkg.lean-dev}";
          };
        };
        shell = shell-utils.myShell.${system};
        leanPkgs = lean.packages.${system};
        pkg = leanPkgs.buildLeanPackage {
          name = "Main"; # must match the name of the top-level .lean file
          roots = [ "Main" "Greeting" ];
          src = ./.;
        };
        makeDeps = pkgs.writeShellApplication {
          name = "makeDeps";
          runtimeInputs = [
            pkg.lean-package
          ];
          text = ''
            ${pkg.lean-package}/bin/lean --deps-json Main.lean > Main-deps.json
          '';
        };
      in
      {
        packages = pkg // {
          inherit (leanPkgs) lean;
          inherit makeDeps;
          inherit vscode;
        };
        defaultPackage = pkg.modRoot;

        devShells.default = shell {
          name = "lean";
          extraInitRc = ''
            alias make-deps=${makeDeps}/bin/makeDeps
          '';
          packages = [
            pkg.modRoot
            pkg.lean-package
          ];
        };
      });
}
