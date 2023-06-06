---
title: Documento de diseño - Practica final DAM1 Sistemas Operativos
author: Víctor García Fernández
date: \today
---

## Introducción

El proyecto ha sido realizado con Docker. De esta forma podemos declarar una maquina con unas características y replicarla como queramos.

Para el servidor web se ha usado nginx.

Se ha usado [nginx](https://hub.docker.com/_/nginx) como la imagen base para la maquina, se trata de un Alpine Linux con nginx instalado.

### Directorios

En el directorio `@/src`\footnote{@ hace referencia a la raíz del proyecto} se encuentran los archivos de código fuente de la maquina.

En el directorio `@/docs` se encuentra el código fuente de la documentación.

### Makefile

Disponemos de un fichero `@/makefile`. En este se encuentran 3 apartados:

- up Ejecuta los comandos necesarios para poner la maquina en marcha.

- down Ejecuta los comandos necesarios para destruir la maquina.\footnote{Persistiendo los backups en un volumen de Docker}

- docs Ejecuta los comandos necesarios para compilar esta documentación.

Para ejecutar cualquier apartado se usa el comando `make nombre_apartado`\footnote{Requiere el paquete make, y pandoc en caso del apartado docs}

## Desarrollo

El fichero principal de este proyecto es `@/src/dockerfile` donde se declaran los comandos a ejecutar para crear la imagen que va a arrancar la maquina, entre otras cosas.

### `@/src/dockerfile`

Con `FROM nginx` usamos la imagen de nginx en el registro de Docker como base para nuestra nueva imagen.

Lo siguiente que hacemos es ejecutar apt-get e instalar los paquetes que vamos a necesitar en la maquina.

Con `WORKDIR /usr/share/nginx/html` establecemos la raíz de las siguientes operaciones al directorio donde nginx sirve ficheros por defecto.

Copiamos el directorio `@/src/html` del proyecto al directorio que hemos establecido como WORKDIR dentro de la maquina con `COPY`.

Hacemos lo mismo con el fichero `@/src/nginx/default.conf` a su ruta `/etc/nginx/conf.d/default.conf`, este es el fichero de configuración del nginx.

Creamos un fichero de autenticación de apache en la ruta `/etc/nginx/.htpasswd` con un usuario admin:secret.

Lo siguiente es copiar todos los scripts de `@/src/scripts` a `/scripts` y darles permiso de ejecución.

Ahora añadimos un par de tareas cron. La primera ejecuta el script `/scripts/htop_html.sh` cada minuto. La segunda ejecuta el script `/scripts/backup.sh` todos los días a las 00:00.

`EXPOSE 80` le dice a la imagen que exponga el puerto 80 para poder conectarnos desde la maquina anfitriona.

Lo ultimo es un "hack" para ejecutar cron y nginx a la vez en un mismo contenedor. Esto se tiene que hacer porque los contenedores no están diseñados para esta arquitectura. Imagino que la solución seria hacer otro container que haga las copias y ejecutarlo en el cron del anfitrión.

### `@/src/nginx/default.conf`

En este fichero se encuentra la configuración del nginx.

Primero declaramos un servidor que escucha en el puerto 80.

Luego le decimos que escriba los accesos en el fichero `/var/log/nginx/host.access.log`.

La primera `location` nos dice que si entramos al servidor por / comprobara si existe el fichero `/usr/share/nginx/html/503.flag` y si no existe nos devolverá el archivo que hemos pedido en la ruta `/usr/share/nginx/html`.

Si el archivo existe nos devolverá un 503.

La siguientes instrucciones `error_page` y `location` nos dicen que si el servidor retornara un 503 retornaría el archivo `503.html`.

A continuación hay una `location` protegida por el usuario y contraseña almacenado en `/etc/nginx/.htpasswd` que sirve el fichero `htop.html`.

La siguiente regla nos devuelve las estadísticas del nginx de la siguiente forma al entrar en `/nginx_status`. Esta protegido por la contraseña usada anteriormente.

```
Active connections: 1
server accepts handled requests
 2 2 6
Reading: 0 Writing: 1 Waiting: 0
```

El resto del archivo nos dice que si el servidor devolviera alguno de esos errores mostraría la pagina `50x.html`.

### `@/src/scripts/backup.sh`

Este script ejecuta un backup de la carpeta `/usr/share/nginx/html` como un `.tar` con la fecha actual como nombre en la carpeta `/media/backup`.

### `@/src/scripts/htop_html.sh`

Este script genera un html con la salida estándar del comando htop en la ruta `/usr/share/nginx/html/htop.html`.
