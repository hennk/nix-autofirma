{ stdenv, lib, fetchzip, makeDesktopItem, unzip, dpkg, bash, temurin-jre-bin-17, openssl }:

stdenv.mkDerivation rec {
  pname = "autofirma";
  version = "1.8.2";

  src = fetchzip {
    url = "https://estaticos.redsara.es/comunes/autofirma/1/8/2/AutoFirma_Linux_Debian.zip";
    sha256 = "sha256-qFY4oOJppL8vx1tC1V2BUyKxlJc8QNqSn98rdejQfFE=";
  };

  desktopItem = makeDesktopItem {
    name = "AutoFirma";
    desktopName = "AutoFirma";
    exec = "AutoFirma %u";
    icon = "AutoFirma";
    mimeTypes = ["x-scheme-handler/afirma"];
    categories = [ "Office" ];
    startupNotify = true;
    startupWMClass = "autofirma";
  };

  buildInputs = [ bash temurin-jre-bin-17 ];
  nativeBuildInputs = [ unzip dpkg openssl ];

  unpackPhase = ''
    dpkg-deb -x $src/AutoFirma_${builtins.replaceStrings ["."] ["_"] version}.deb .
  '';

  buildPhase = ''
    # Creates local Root CA, creates a local server certificate for the AutoFirma app, and deletes the Root CA key, so no further certificates can be generated
    ${temurin-jre-bin-17}/bin/java -jar usr/lib/AutoFirma/AutoFirmaConfigurador.jar
    # Create a PEM-encoded copy of the Root CA certificate, for easier integration with linux stores
    ${openssl}/bin/openssl x509 -in usr/lib/AutoFirma/AutoFirma_ROOT.cer -out usr/lib/AutoFirma/AutoFirma_ROOT.pem
  '';

  installPhase = ''
    install -Dm644 usr/lib/AutoFirma/AutoFirma.jar $out/share/AutoFirma/AutoFirma.jar
    install -Dm644 usr/lib/AutoFirma/AutoFirmaConfigurador.jar $out/share/AutoFirma/AutoFirmaConfigurador.jar
    install -Dm644 usr/share/AutoFirma/AutoFirma.svg $out/share/AutoFirma/AutoFirma.svg
    install -Dm644 usr/lib/AutoFirma/AutoFirma.png $out/share/pixmaps/AutoFirma.png

    install -d $out/bin
    cat > $out/bin/AutoFirma <<EOF
    #!${bash}/bin/sh
    ${temurin-jre-bin-17}/bin/java -Djdk.tls.maxHandshakeMessageSize=65536 -jar $out/share/AutoFirma/AutoFirma.jar "\$@"
    EOF
    chmod +x $out/bin/AutoFirma

    install -Dm644 usr/lib/AutoFirma/AutoFirma_ROOT.cer $out/share/AutoFirma/AutoFirma_ROOT.cer
    install -Dm644 usr/lib/AutoFirma/AutoFirma_ROOT.pem $out/share/AutoFirma/AutoFirma_ROOT.pem
    install -Dm644 usr/lib/AutoFirma/autofirma.pfx $out/share/AutoFirma/autofirma.pfx

    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications/
  '';

  meta = with lib; {
    description = "Spanish Government digital signature tool";
    homepage = "https://firmaelectronica.gob.es/Home/Ciudadanos/Aplicaciones-Firma.html";
    license = with licenses; [ gpl2Only eupl11 ];
    platforms = platforms.linux;
  };
}
