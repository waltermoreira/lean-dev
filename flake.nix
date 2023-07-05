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
        myShell = shell-utils.myShell.${system};
        leanPkgs = lean.packages.${system};
        buildLeanPackage = args:
          let
            pkg = leanPkgs.buildLeanPackage args;
            vscode = myvscode.makeMyVSCode pkgs {
              extraExtensions = [
                vscode-lean4
              ];
              extraSettings = {
                "lean4.toolchainPath" = "${pkg.lean-package}";
              };
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
            shell =
              { extraInitRc ? ""
              , packages ? [ ]
              , ...
              }@args:
              let
                newExtraInitRc = ''
                  ${extraInitRc}
                  alias make-deps=${makeDeps}/bin/makeDeps
                '';
                newPackages = [
                  pkg.modRoot
                  pkg.lean-package
                  vscode
                ] ++ packages;
              in
              myShell (
                args // {
                  extraInitRc = newExtraInitRc;
                  packages = newPackages;
                }
              );
          in
          pkg // {
            inherit vscode shell;
          };
        pkg = buildLeanPackage {
          name = "Main";
          roots = [ "Main" ];
          src = ./.;
        };
      in
      {
        lib = {
          inherit buildLeanPackage;
        };
        packages = pkg;
        devShells.default =
          pkg.shell {
            name = "example";
          };
      });
}
