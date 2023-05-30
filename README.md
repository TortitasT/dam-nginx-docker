# DAM nginx Docker

Made for DAM1 Sistemas Operativos. It should bootstrap a sample nginx server with 503 mantainence flag support.

## Usage

To bootstrap and start the server.

```bash
make up
```

To shutdown the server.

```bash
make down
```

To enable mantainence mode create a file `503.flag` on the document root.

```
touch 503.flag
```
