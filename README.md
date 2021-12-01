# matrix-hook

Matrix webhook receiver based on
[matrix-alertmanager-receiver](https://git.sr.ht/~fnux/matrix-alertmanager-receiver).
Listens for webhooks from promehteus alertmanager and sends a message to a
matrix channel.

Configuration is done with environment variables.



| Variable      | Description         | Example                      |
|---------------|---------------------|------------------------------|
| HTTP_ADDRESS  | Adress to listen on | `localhost`                  |
| HTTP_PORT     | Port to listen on   | `8080`                       |
| MX_HOMESERVER | Matrix homeserver   | `matrix.org`                 |
| MX_ID         | Matrix user ID      | `@mr_panic:matrix.org`       |
| MX_ROOMID     | Matrix room to join | `!ilXTTTTTTuDmsz:matrix.org` |
| MX_TOKEN      | Matrix access token | `rstienrsrseintrisetnrte`    |


# Nix

For Nix/Nixos users a `flake.nix` is provided to simplify the build. It also
privides app to test the hooks with mocked data from `mock.json`

### Build

```sh
nix build
```

### Run directly

```sh
nix run
```

### Test alerts

```sh
nix run '.#mock-hook'
```

### Module

The flake also includes a NixOS module for ease of use. A minimal configuration
will look like this:

```nix

# Add to flake inputs
inputs.matrix-hook.url = "github:pinpox/matrix-hook";

# Import the module in your configuration.nix
imports = [
  self.inputs.matrix-hook.nixosModules.matrix-hook
];

# Enable and set options
services.matrix-hook = {
  enable = true;
  httpAddress = "localhost";
  matrixHomeserver = "https://matrix.org";
  matrixUser = "@mr_panic:matrix.org";
  matrixRoom = "!ilXXXXXXXXXXXXXXXz:matrix.org";
  envFile = "/var/src/secrets/matrix-hook/envfile";
};
```
