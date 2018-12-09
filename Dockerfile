FROM debian:9.5-slim

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="hello@mazzotta.me" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Docker Nginx LUA" \
    org.label-schema.description="Docker for Nginx with Luajit, More Headers and Google Pagespeed preinstalled" \
    org.label-schema.url="https://github.com/emazzotta/docker-nginx-lua" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/emazzotta/docker-nginx-lua" \
    org.label-schema.vendor="Emanuele Mazzotta" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

RUN apt-get update && apt-get install -qqy --no-install-recommends \
    wget \
    build-essential \
    linux-kernel-headers \
    libpcre3 \
    libpcre3-dev \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
ENV NGINX_TEMP_DIR=/tmp/nginx
ENV NGINX_DIR=/etc/nginx

# http://nginx.org/en/download.html
ENV NGINX_VERSION=1.15.7
# https://github.com/simpl/ngx_devel_kit/releases
ENV NGINX_DEV_VERSION=0.3.1rc1
# http://luajit.org/download.html
ENV LUA_JIT_VERSION=2.0.5
# https://github.com/openresty/lua-nginx-module/releases
ENV LUA_VERSION=0.10.13
# https://www.openssl.org/source/
ENV OPENSSL_VERSION=1.0.2q
# https://github.com/openresty/headers-more-nginx-module/releases
ENV HEADERS_MORE_VERSION=0.33
# https://github.com/pagespeed/ngx_pagespeed/releases
ENV GOOGLE_PAGESPEED_VERSION=1.12.34.3-stable

ENV NGX_DEV_MODULE_PATH=$NGINX_TEMP_DIR/ngx_devel_kit-$NGINX_DEV_VERSION
ENV LUAJIT_MODULE_PATH=$NGINX_TEMP_DIR/LuaJIT-$LUA_JIT_VERSION
ENV LUA_MODULE_PATH=$NGINX_TEMP_DIR/lua-nginx-module-$LUA_VERSION
ENV OPENSSL_MODULE_PATH=$NGINX_TEMP_DIR/openssl-$OPENSSL_VERSION
ENV HEADERS_MORE_MODULE_PATH=$NGINX_TEMP_DIR/headers-more-nginx-module-$HEADERS_MORE_VERSION
ENV GOOGLE_PAGESPEED_MODULE_PATH=$NGINX_TEMP_DIR/incubator-pagespeed-ngx-$GOOGLE_PAGESPEED_VERSION

RUN mkdir -p $NGINX_TEMP_DIR
WORKDIR $NGINX_TEMP_DIR

RUN wget --no-check-certificate http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
        -P $NGINX_TEMP_DIR/ && \
        tar xzvf nginx-$NGINX_VERSION.tar.gz --strip-components=1 && \
        rm -rf nginx-$NGINX_VERSION.tar.gz

RUN wget --no-check-certificate https://github.com/simpl/ngx_devel_kit/archive/v$NGINX_DEV_VERSION.tar.gz \
        -O $NGX_DEV_MODULE_PATH.tar.gz && \
        tar xzvf $NGX_DEV_MODULE_PATH.tar.gz && \
        rm -rf $NGX_DEV_MODULE_PATH.tar.gz

RUN wget --no-check-certificate http://luajit.org/download/LuaJIT-$LUA_JIT_VERSION.tar.gz \
        -O $LUAJIT_MODULE_PATH.tar.gz && \
        tar xzvf $LUAJIT_MODULE_PATH.tar.gz && \
        cd $LUAJIT_MODULE_PATH && \
        make && \
        make install && \
        rm -rf $LUAJIT_MODULE_PATH.tar.gz

RUN wget --no-check-certificate https://github.com/chaoslawful/lua-nginx-module/archive/v$LUA_VERSION.tar.gz \
        -O $LUA_MODULE_PATH.tar.gz && \
        tar xzvf $LUA_MODULE_PATH.tar.gz && \
        rm -rf $LUA_MODULE_PATH.tar.gz

RUN wget --no-check-certificate https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_VERSION.tar.gz \
        -O $HEADERS_MORE_MODULE_PATH.tar.gz && \
        tar xzvf $HEADERS_MORE_MODULE_PATH.tar.gz && \
        rm -rf $HEADERS_MORE_MODULE_PATH.tar.gz

RUN wget --no-check-certificate https://openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz \
        -O $OPENSSL_MODULE_PATH.tar.gz && \
        tar xzvf $OPENSSL_MODULE_PATH.tar.gz && \
        rm -rf $OPENSSL_MODULE_PATH.tar.gz

RUN wget --no-check-certificate https://github.com/pagespeed/ngx_pagespeed/archive/v$GOOGLE_PAGESPEED_VERSION.tar.gz \
        -O $GOOGLE_PAGESPEED_MODULE_PATH.tar.gz && \
        tar xzvf $GOOGLE_PAGESPEED_MODULE_PATH.tar.gz && \
        cd $GOOGLE_PAGESPEED_MODULE_PATH && \
        wget --no-check-certificate $(scripts/format_binary_url.sh PSOL_BINARY_URL) -O psol-$GOOGLE_PAGESPEED_VERSION.tar.gz && \
        tar xzvf psol-$GOOGLE_PAGESPEED_VERSION.tar.gz && \
        rm -rf $GOOGLE_PAGESPEED_MODULE_PATH.tar.gz && \
        rm -rf psol-$GOOGLE_PAGESPEED_VERSION.tar.gz

RUN ./configure \
        --prefix=$NGINX_DIR \
        --add-module=$GOOGLE_PAGESPEED_MODULE_PATH \
        --add-module=$LUA_MODULE_PATH \
        --add-module=$NGX_DEV_MODULE_PATH \
        --add-module=$HEADERS_MORE_MODULE_PATH \
        --with-openssl=$OPENSSL_MODULE_PATH \
        --with-http_v2_module \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-file-aio \
        --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security' \
        --with-ld-opt=-Wl,-z,relro \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx && \
        make && \
        make install && \
        rm -rf /tmp/nginx

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR $NGINX_DIR

ADD nginx.conf /etc/nginx/nginx.conf
ADD mime.types /etc/nginx/mime.types
RUN mkdir -p /etc/nginx/conf.d

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
