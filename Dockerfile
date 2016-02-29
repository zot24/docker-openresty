FROM alpine:3.3
MAINTAINER Israel Sotomayor <sotoisra24@gmail.com>

ENV TMP_DIR /tmp
ENV VAR_PREFIX /var/nginx
ENV OPENRESTY_VERSION openresty-1.9.7.3
ENV OPENRESTY_PREFIX /opt/openresty
ENV NGINX_PREFIX /opt/openresty/nginx

WORKDIR $TMP_DIR
RUN echo "==> Installing OpenResty dependencies ..." \
  && apk --no-cache add --virtual build-dependencies \
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
  && echo "==> Downloading OpenResty ..." \
  && curl -sSL http://openresty.org/download/$OPENRESTY_VERSION.tar.gz | tar -xz \
  && cd $TMP_DIR/$OPENRESTY_VERSION \
  && echo "==> Configuring OpenResty ..." \
  && readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && echo "using upto $NPROC threads" \
  && ./configure \
    --prefix=$OPENRESTY_PREFIX \
    --http-client-body-temp-path=$VAR_PREFIX/client_body_temp \
    --http-proxy-temp-path=$VAR_PREFIX/proxy_temp \
    --http-log-path=$VAR_PREFIX/access.log \
    --error-log-path=$VAR_PREFIX/error.log \
    --pid-path=$VAR_PREFIX/nginx.pid \
    --lock-path=$VAR_PREFIX/nginx.lock \
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
  && echo "==> Building OpenResty ..." \
  && make -j${NPROC} \
  && echo "==> Installing OpenResty ..." \
  && make install \
  && echo "==> Cleaning up OpenResty installation ..." \
  && rm -rf $TMP_DIR/$OPENRESTY_VERSION \
  && apk del build-dependencies \
  && rm -rf ~/.cache

RUN ln -sf $NGINX_PREFIX/sbin/nginx /usr/local/bin/nginx \
  && ln -sf $NGINX_PREFIX/sbin/nginx /usr/local/bin/openresty \
  && ln -sf $OPENRESTY_PREFIX/bin/resty /usr/local/bin/resty \
  && ln -sf $OPENRESTY_PREFIX/luajit/bin/luajit-* $OPENRESTY_PREFIX/luajit/bin/lua \
  && ln -sf $OPENRESTY_PREFIX/luajit/bin/luajit-* /usr/local/bin/lua

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
