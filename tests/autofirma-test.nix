(import ./common/lib.nix) {
  name = "Autofirma";
  nodes = {
    machine = { self, pkgs, ... }: {
      imports = [ ./common/x11.nix self.nixosModules.autofirma ];
      programs.autofirma.enable = true;
      programs.autofirma.package = self.legacyPackages.x86_64-linux.autofirma;
      environment.systemPackages = [
        pkgs.curl
      ];
    };
  };

  testScript = ''
    start_all()
    machine.wait_for_x()

    machine.succeed("AutoFirma 'afirma://websocket?v=3&idsession=VIdJm2X3HP6TMYcrF3Ld' >&2 &")
    machine.wait_for_open_port(63117, "localhost", 30)
    machine.wait_until_succeeds("curl https://localhost:63117", 10)
  '';
}
