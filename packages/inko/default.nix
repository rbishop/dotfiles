{
  lib
  , stdenv
  , fetchFromGitHub
  , libffi
  , zlib
  , libxml2
  , ncurses
  , llvmPackages_16
  , rustPlatform
}:

rustPlatform.buildRustPackage rec {
  name = "inko";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "inko";
    rev = "v${version}";
    sha256 = "sha256-Iojv8pTyILYpLFnoTlgUGmlfWWH0DgsGBRxzd3oRNwA=";
  };

  cargoHash = "sha256-LyyyN70N2J78Y10wLYxr/50rF+LIVxbdeZKQVdki2dA=";

  propagatedBuildInputs = [ ncurses ];

  nativeBuildInputs = [ llvmPackages_16.llvm.dev ];

  buildInputs = [ libffi zlib libxml2 ];

  buildPhase = ''
    make PREFIX=$out
  '';

  installPhase = ''
    make install PREFIX=$out
  '';

  postInstall = ''
    cp -r ./std $out/
  '';

  checkFlags = [
    # git clone tests fail
    "--skip=pkg::git::tests"
  ];
}
