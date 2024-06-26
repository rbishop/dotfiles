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
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "inko-lang";
    repo = "inko";
    rev = "96ded0592c06dd6c930839180c8758bd6fccae9a";
    #sha256 = "sha256-6NnTqc9V/Ck4Dzo6ZcWLpCNQQVym55gQ3q7w+0DXiDc=";
    sha256 = "sha256-7tqt2xLdSanYXf6WtcHn+OpTTsrjj2Arcg/b5rD27yw=";
  };

  #cargoSha256 = "sha256-bXW3OJlXDOrqgx8OPW5xj9yS+QGZVSTXkpmy5klEAZk=";
  cargoHash = "sha256-ZqoA2qHG+6jgi3JEHflFg9kvcR5fdru3yWWqeZfr/Bs=";

  propagatedBuildInputs = [ ncurses ];

  nativeBuildInputs = [ llvmPackages_16.llvm.dev ];

  buildInputs = [ libffi zlib libxml2 ];

  buildPhase = ''
    make PREFIX=$out
  '';

  installPhase = ''
    make install PREFIX=$out
  '';

  #env = {
  #  INKO_STD = "${out}/std/src";
  #};

  postInstall = ''
    cp -r ./std $out/std
  '';

  checkFlags = [
    # git clone tests fail
    "--skip=pkg::git::tests"
  ];
}
