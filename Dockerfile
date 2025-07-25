FROM debian:bookworm-slim as builder
LABEL maintainer="Thomas Michel <thomas.michel@idgeo.fr>"

ENV MAPCACHE_VERSION=branch-1-14

RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends ca-certificates git cmake build-essential \
        liblz-dev libpng-dev libgdal-dev libgeos-dev libpixman-1-dev libsqlite3-dev libcurl4-openssl-dev \
        libaprutil1-dev libapr1-dev libjpeg62-turbo-dev libdpkg-dev libdb5.3-dev libtiff5-dev libpcre3-dev \
        apache2 apache2-dev postgresql-server-dev-all

RUN mkdir /build && \
    mkdir /etc/mapcache && \
    ln --symbolic /etc/mapcache /mapcache && \
    cd /build && \
    git clone https://github.com/mapserver/mapcache.git && \
    cd /build/mapcache && \
    git checkout ${MAPCACHE_VERSION} && \
    mkdir /build/mapcache/build && \
    cd /build/mapcache/build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DWITH_MEMCACHE=1 -DWITH_FCGI=0 -DWITH_CGI=0 -DWITH_POSTGRESQL=0 -DWITH_SQLITE=1 -DWITH_PCRE=1 -DWITH_PIXMAN=1 -DWITH_OGR=1 .. && \
    make && \
    make install && \
    ldconfig && \
    cp /build/mapcache/mapcache.xml /mapcache/ && \
    rm -Rf /build

FROM debian:bookworm-slim as runner
LABEL maintainer="thomas.michel@idgeo.fr"

ENV APACHE_CONFDIR=/etc/apache2 \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=/var/run/apache2/apache2.pid \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_LOG_DIR=/var/log/apache2 \
    LANG=C \
    TERM=linux

RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends ca-certificates \
        libgdal32 libaprutil1 libapr1 libpixman-1-0 libdb5.3 libpcre3 \
        apache2 libpq5 curl vim libfcgi-dev libgdal-dev libgeos-dev libsqlite3-dev libtiff5-dev \
        libdb5.3-dev liblmdb-dev && \
    apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/partial/* /tmp/* /var/tmp/* && \
    adduser www-data root && \
    mkdir --parent ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR} && \
    chmod -R g+w /etc/apache2 ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR}

COPY --from=builder /usr/local/bin /usr/local/bin/
COPY --from=builder /usr/local/lib /usr/local/lib/
COPY --from=builder /usr/lib/apache2/modules/mod_mapcache.so /usr/lib/apache2/modules/mod_mapcache.so
COPY --from=builder /etc/mapcache/mapcache.xml /etc/mapcache/mapcache.xml

RUN ln --symbolic /etc/mapcache /mapcache
RUN ldconfig

COPY mapcache.conf /etc/apache2/conf-enabled/
COPY mapcache.load /etc/apache2/mods-available/
COPY mapcache.xml /var/www/mapcache/mapcache.xml
COPY start-server /usr/bin/

ENV MAX_REQUESTS_PER_PROCESS=1000 \
    SERVER_LIMIT=16 \
    MAX_REQUEST_WORKERS=400 \
    THREADS_PER_CHILD=25 \
    MIN_SPARE_THREADS=75

RUN a2enmod mapcache rewrite && \
    a2dismod -f auth_basic authn_file authn_core authz_host authz_user autoindex dir status && \
    rm /etc/apache2/mods-enabled/alias.conf && \
    find "${APACHE_CONFDIR}" -type f -exec sed -ri ' \
       s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
       s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
       ' '{}' ';'
RUN ldconfig

WORKDIR /etc/mapcache

EXPOSE 80

CMD ["start-server"]
