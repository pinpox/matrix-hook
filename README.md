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
