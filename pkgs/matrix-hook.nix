{ buildGoModule, lib, vendorHash ? "sha256-hiO8EKQnvX1iJmUSEzFDClqnGjUgrLWgjlMFuACbNl0=" }:

buildGoModule {
  pname = "matrix-hook";
  version = "1.0.0";

  src = ./..;
  inherit vendorHash;
  subPackages = [ "." ];
  installPhase = ''
    mkdir -p $out/bin
    cp $GOPATH/bin/matrix-hook $out/bin/matrix-hook
    cp message.html.tmpl $out/bin/message.html.tmpl
  '';

  # mkdir -p $out/bin
  # mv matrix-hook $out/bin/matrix-hook
  meta = with lib; {
    description = "Relay prometheus alerts as matrix messages";
    homepage = "https://github.com/pinpox/matrix-hook";
    license = licenses.gpl3;
    maintainers = with maintainers; [ pinpox ];
  };
}
