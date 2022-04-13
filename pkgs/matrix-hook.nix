{ pkgs ? import <nixpkgs> {} }:

pkgs.buildGoModule rec {

  pname = "matrix-hook";
  version = "1.0.0";

  src = ./.;
  vendorSha256 =
    "sha256-185Wz9IpJRBmunl+KGj/iy37YeszbT3UYzyk9V994oQ=";
    subPackages = [ "." ];
    installPhase = ''
              mkdir -p $out/bin
              cp $GOPATH/bin/matrix-hook $out/bin/matrix-hook
              cp message.html.tmpl $out/bin/message.html.tmpl
    '';

    # mkdir -p $out/bin
    # mv matrix-hook $out/bin/matrix-hook
    meta = with pkgs.lib; {
      description = "Relay prometheus alerts as matrix messages";
      homepage = "https://github.com/pinpox/matrix-hook";
      license = licenses.gpl3;
      maintainers = with maintainers; [ pinpox ];
    };
  };
