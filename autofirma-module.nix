{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.autofirma;
in {
  options.programs.autofirma = {
    enable = lib.mkEnableOption "Installs the AutoFirma application and adds its custom CA to the system's CA store.";

    package = lib.mkPackageOption pkgs "autofirma" {
      extraDescription = ''
        This can be used to install a custom autofirma package.
      '';
    };

    scReaderSupport = lib.mkEnableOption "Install packages needed for Smartcard Reader support.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ] ++ lib.lists.optionals cfg.scReaderSupport [ pkgs.ccid pkgs.pcsclite pkgs.opensc pkgs.scmccid ];
    security.pki.certificateFiles = [
      "${cfg.package}/share/AutoFirma/AutoFirma_ROOT.pem"
    ];
  };

}