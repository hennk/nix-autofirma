{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  outputs = { self, nixpkgs, ...}: let
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
  in {
    nixosModules.autofirma = import ./autofirma-module.nix;
    legacyPackages = forAllSystems (system: {autofirma = nixpkgs.legacyPackages.${system}.callPackage ./autofirma.nix {}; } );
    checks = forAllSystems (system: let
      checkArgs = {
        # reference to nixpkgs for the current system
        pkgs = nixpkgs.legacyPackages.${system};
        # this gives us a reference to our flake but also all flake inputs
        inherit self;
      };
    in {
      # import our test
      autofirma = import ./tests/autofirma-test.nix checkArgs;
    });
  };
}