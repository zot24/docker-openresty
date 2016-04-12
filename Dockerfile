FROM alpine:3.3
MAINTAINER Israel Sotomayor <sotoisra24@gmail.com>

ENV LUA_SUFFIX=jit-2.1.0-beta1 \
    LUAJIT_VERSION=2.1 \
    NGINX_PREFIX=/opt/openresty/nginx \
    OPENRESTY_PREFIX=/opt/openresty \
    OPENRESTY_SRC_SHA1=653bb9977c0cbf164fbd195df4180e91d25a3f92 \
    OPENRESTY_VERSION=1.9.7.4 \
    VAR_PREFIX=/var/nginx

RUN set -ex \
  && apk --no-cache add --virtual .build-dependencies \
    curl \
    make \
    musl-dev \
    gcc \
    ncurses-dev \
    openssl-dev \
    pcre-dev \
    perl \
    readline-dev \
    zlib-dev \
  \
  && curl -fsSL http://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz -o /tmp/openresty.tar.gz \
  \
  && cd /tmp \
  && echo "${OPENRESTY_SRC_SHA1} *openresty.tar.gz" | sha1sum -c - \
  && tar -xzf openresty.tar.gz \
  \
  && cd openresty-* \
  && readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && ./configure \
    --prefix=${OPENRESTY_PREFIX} \
    --http-client-body-temp-path=${VAR_PREFIX}/client_body_temp \
    --http-proxy-temp-path=${VAR_PREFIX}/proxy_temp \
    --http-log-path=${VAR_PREFIX}/access.log \
    --error-log-path=${VAR_PREFIX}/error.log \
    --pid-path=${VAR_PREFIX}/nginx.pid \
    --lock-path=${VAR_PREFIX}/nginx.lock \
    --with-luajit \
    --with-pcre-jit \
    --with-ipv6 \
    --with-http_ssl_module \
    --without-http_ssi_module \
    --with-http_realip_module \
    --without-http_scgi_module \
    --without-http_uwsgi_module \
    --without-http_userid_module \
    -j${NPROC} \
  && make -j${NPROC} \
  && make install \
  \
  && rm -rf /tmp/openresty-* \
  && apk del .build-dependencies

RUN ln -sf ${NGINX_PREFIX}/sbin/nginx /usr/local/bin/nginx \
  && ln -sf ${NGINX_PREFIX}/sbin/nginx /usr/local/bin/openresty \
  && ln -sf ${OPENRESTY_PREFIX}/bin/resty /usr/local/bin/resty \
  && ln -sf ${OPENRESTY_PREFIX}/luajit/bin/luajit-* ${OPENRESTY_PREFIX}/luajit/bin/lua \
  && ln -sf ${OPENRESTY_PREFIX}/luajit/bin/luajit-* /usr/local/bin/lua

RUN apk --no-cache add \
    libgcc \
    libpcrecpp \
    libpcre16 \
    libpcre32 \
    libssl1.0 \
    libstdc++ \
    openssl \
    pcre

WORKDIR $NGINX_PREFIX

CMD ["nginx", "-g", "daemon off; error_log /dev/stderr info;"]
