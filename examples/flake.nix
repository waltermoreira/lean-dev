{
  description = "Lean Example";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    lean-dev.url = "path:/Users/waltermoreira/repos/lean-dev";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, lean-dev, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        lean = lean-dev.lib.${system};
        pkg = lean.buildLeanPackage {
          name = "Main"; # must match the name of the top-level .lean file
          roots = [ "Main" "Greeting" ];
          src = ./.;
        };
      in
      {
        packages = pkg;
        devShells.default = pkg.shell {
          name = "demo";
        };
      });
}
