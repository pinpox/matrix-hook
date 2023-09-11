{ pkgs ? import <nixpkgs> {}
, vendorHash ? "sha256-hiO8EKQnvX1iJmUSEzFDClqnGjUgrLWgjlMFuACbNl0="
}:

pkgs.buildGoModule {
  pname = "http2irc";
  version = "0.1";
  
  src = ./.;
  inherit vendorHash;
  subPackages = [ "." ];
  
  meta = with pkgs.lib; {
    description = "Webhook reciever to annouce in IRC channels";
    homepage = "https://github.com/pinpox/http2irc";
    license = licenses.gpl3;
    maintainers = with maintainers; [ pinpox ];
    platforms = platforms.linux;
  };
}
