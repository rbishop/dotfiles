{
  outputs = { self, nixpkgs, flake-utils, }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell.override { stdenv = pkgs.swift.stdenv; } {
          buildInputs = with pkgs; [ swift swiftpm swiftPackages.Foundation ];
        };
      });
}

