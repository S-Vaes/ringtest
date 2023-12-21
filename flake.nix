{
  description = "Lock-free ringbuffer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        ringbuffer = pkgs.stdenv.mkDerivation {
          name = "ringbuffer";
          src = self;
          buildInputs = with pkgs;
            [
              cmake
            ];
          buildPhase = ''
            cmake .
            make
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp my-binary $out/bin/
          '';
        };
      in
      {
        packages = {
          inherit ringbuffer;
        };
        defaultPackage = ringbuffer;
        devShell =  (pkgs.mkShell.override { stdenv = pkgs.gcc13Stdenv; }) {
          name = "ringbuffer";
          buildInputs = with pkgs;
            [
              clang-tools_17
              cmake
              gcc13

              catch2_3
              trompeloeil
            ];
        };
      }
    );
}
