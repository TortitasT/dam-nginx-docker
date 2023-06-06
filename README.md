# DAM nginx Docker

Made for DAM1 Sistemas Operativos. It should bootstrap a sample nginx server with 503 mantainence flag support. When more than 1 user is connected it should put itself in mantainance.

DISCLAIMER: Just a demo :)

## Usage

To bootstrap and start the server.

```bash
make up
```

To shutdown the server.

```bash
make down
```

To enable mantainence mode create a file `503.flag` on the document root `/usr/share/nginx/html`.

```
touch 503.flag
```
