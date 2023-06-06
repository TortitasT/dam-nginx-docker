---
title: Documento técnico - Practica final DAM1 Sistemas Operativos
author:
  - Asier Gilaber Garcelan
  - Jose Manuel Carrasco
  - Víctor García Fernández
date: \today
---

## Introducción

El proyecto ha sido realizado con Docker. De esta forma podemos declarar una maquina con unas características y replicarla como queramos.

Código en el repositorio git [https://github.com/TortitasT/dam-nginx-docker.git](https://github.com/TortitasT/dam-nginx-docker.git)

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

## Funcionalidades

- 503 Se detecta cuando hay mas de 1 usuario conectado y se devuelven 503.

- htop.html El administrador puede monitorizar los procesos del contenedor desde el navegador desde la ruta /htop.html protegida por el usuario `admin` con contraseña `secret`.

- backups Se guarda un backup de la carpeta `/usr/share/nginx/html` cada lunes a las 00:00 en el volumen de Docker `backup`.

- 504.flag Si el administrador creara un archivo `503.flag` en la ruta `/usr/share/nginx/html` el servidor devolvería 503. De esta forma se pondría en mantenimiento de forma manual.

## Explicación de los ficheros mas importantes

El fichero principal de este proyecto es `@/src/dockerfile` donde se declaran los comandos a ejecutar para crear la imagen que va a arrancar la maquina, entre otras cosas.

### `@/src/dockerfile`

Con `FROM nginx` usamos la imagen de nginx en el registro de Docker como base para nuestra nueva imagen.

Lo siguiente que hacemos es ejecutar apt-get e instalar los paquetes que vamos a necesitar en la maquina.

Con `WORKDIR /usr/share/nginx/html` establecemos la raíz de las siguientes operaciones al directorio donde nginx sirve ficheros por defecto.

Copiamos el directorio `@/src/html` del proyecto al directorio que hemos establecido como WORKDIR dentro de la maquina con `COPY`.

Hacemos lo mismo con el fichero `@/src/nginx/default.conf` a su ruta `/etc/nginx/conf.d/default.conf`, este es el fichero de configuración del nginx.

Creamos un fichero de autenticación de apache en la ruta `/etc/nginx/.htpasswd` con un usuario admin:secret.

Lo siguiente es copiar todos los scripts de `@/src/scripts` a `/scripts` y darles permiso de ejecución.

Ahora añadimos tres tareas cron. La primera ejecuta el script `/scripts/htop_html.sh` cada minuto. La segunda ejecuta el script `/scripts/backup.sh` todos los lunes a las 00:00. Y la ultima ejecuta el script `/scripts/check_nginx_saturation` cada 5 minutos.

`EXPOSE 80` le dice a la imagen que exponga el puerto 80 para poder conectarnos desde la maquina anfitriona.

Lo ultimo es un "hack" para ejecutar cron y nginx a la vez en un mismo contenedor. Esto se tiene que hacer porque los contenedores no están diseñados para esta arquitectura. Imagino que la solución seria hacer otro container que haga las copias y ejecutarlo en el cron del anfitrión.

### `@/docker-compose.yml`

En este fichero se encuentra la configuración a ejecutar cuando hagamos `make up`. Lo importante es que se declara el volumen `backup` de forma que se monte en `/media/backup` para poder hacer las copias.

### `@/src/nginx/default.conf`

En este fichero se encuentra la configuración del nginx.

Primero declaramos un servidor que escucha en el puerto 80.

Luego le decimos que escriba los accesos en el fichero `/var/log/nginx/host.access.log`.

La primera `location` nos dice que si entramos al servidor por / comprobara si existe el fichero `/usr/share/nginx/html/503.flag` o `/tmp/nginx_saturation` y si no ninguno nos devolverá el archivo que hemos pedido en la ruta `/usr/share/nginx/html`.

Si alguno de los archivos existen nos devolverá un 503.

La siguientes instrucciones `error_page` y `location` nos dicen que si el servidor retornara un 503 retornaría el archivo `503.html`.

A continuación hay una `location` protegida por el usuario y contraseña almacenado en `/etc/nginx/.htpasswd` que sirve el fichero `htop.html`.

La siguiente regla nos devuelve las estadísticas del nginx de la siguiente forma al entrar en `/nginx_status`.

```
Active connections: 1
server accepts handled requests
 2 2 6
Reading: 0 Writing: 1 Waiting: 0
```

Solo puede acceder localhost, esto es usado para saber en numero de usuarios conectados por el script `@/src/scripts/check_nginx_saturation.sh`.

El resto del archivo nos dice que si el servidor devolviera alguno de esos errores mostraría la pagina `50x.html` o `404.html` en caso del 404. También se deniega el acceso a todos los archivos que empiecen por `.ht` pues si los hubiera contendrían información sensible sobre la configuración del servidor web.

### `@/src/scripts/backup.sh`

Este script ejecuta un backup de la carpeta `/usr/share/nginx/html` como un `.tar` con la fecha actual como nombre en la carpeta `/media/backup`.

### `@/src/scripts/htop_html.sh`

Este script genera un html con la salida estándar del comando htop en la ruta `/usr/share/nginx/html/htop.html`.

### `@/src/scripts/check_nginx_saturation.sh`

Este script comprueba mediante el `location` `/nginx_status` los usuarios conectados y si hay mas de 1\footnote{Para que se pueda testear} pone el servicio en mantenimiento creando un archivo `/tmp/nginx_saturation`.
