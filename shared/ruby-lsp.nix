{ pkgs, ... }:

let
  prism = pkgs.rubyPackages_3_3.prism.override {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "sha256-pSyEOgMIp/X68o6avTbjKEKA/Hw0rLoF2FjLAJunR18=";
      type = "gem";
    };
    version = "0.29.0";
  };

  language_server-protocol = pkgs.rubyPackages_3_3.language_server-protocol.override {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "sha256-PVxYwC9Eog2XKVep/r44bX50aKs5AM5r0rVj3ZEMaz8=";
      type = "gem";
    };
    version = "3.17.0.3";
  };

  sorbet-runtime = pkgs.rubyPackages_3_3.sorbet-runtime.override {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "sha256-WS4Iw8imhrbeHodI1yaw0x1ZUIv2HkBz06Artchgiz8=";
      type = "gem";
    };
    version = "0.5.11409";
  };

in
  pkgs.buildRubyGem {
    name = "ruby-lsp";
    gemName = "ruby-lsp";
    version = "0.17.1";
    ruby = pkgs.ruby_3_3; 
    buildInputs = [ language_server-protocol prism sorbet-runtime ];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "sha256-5ZuR4SYpd+eP36muL8oaloWe9qqkISJq+MSe8YkTrZM=";
      type = "gem";
    };
  }
