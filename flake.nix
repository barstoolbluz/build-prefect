{
  description = "Prefect workflow orchestration platform (unofficial Nix package)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Import our Nix expression from .flox/pkgs/
        prefect = pkgs.callPackage ./.flox/pkgs/prefect.nix { };
      in
      {
        packages = {
          default = prefect;
          prefect = prefect;
        };

        apps = {
          default = {
            type = "app";
            program = "${prefect}/bin/prefect";
          };
          prefect-server = {
            type = "app";
            program = "${prefect}/bin/prefect";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ prefect ];
          inputsFrom = [ prefect ];
        };
      });
}
