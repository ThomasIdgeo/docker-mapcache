## Docker Mapcache 1.14

Ce repo contient le dockerfile pour produire une image docker. Accompagnée de quelques fichiers de conf personnalisables.

Compilation depuis les sources d'un serveur mapcache en version 1.14
https://github.com/mapserver/mapcache.git



```bash
docker build -t thomasidgeo/mapcache:1.14 .
```

>[!WARNING]
>La doc n'est pas à jour sur certaines versions des dépendances [https://mapserver.org/mapcache/install.html](https://mapserver.org/mapcache/install.html)</br>
>libgdal32 libgdal-dev libsqlite3-dev libtiff5-dev libdb5.3-dev

Se connecter à dockerhub

```bash
docker login
```

Pousser l'image sur le repo distant.

```bash
docker push thomasidgeo/mapcache:1.14
```
L'image docker est disponible sur [dockerhub](https://hub.docker.com/repository/docker/thomasidgeo/mapcache/general).

## Documentation Usage

Bientôt