## Docker Mapcache 1.14

Compilation depuis les sources d'un serveur mapcache en version 1.14
https://github.com/mapserver/mapcache.git



```bash
docker build -t thomasidgeo/mapcache:1.14 .
```

!!! note

    La doc n'est pas à jour surcertaines versions des dépendances [https://mapserver.org/mapcache/install.html](https://mapserver.org/mapcache/install.html)
    libgdal32 libgdal-dev libsqlite3-dev libtiff5-dev libdb5.3-dev

Se connecter à dockerhub

```bash
docker login
```

Pousser l'image sur le repo.

```bash
docker push thomasidgeo/mapcache:1.14
```