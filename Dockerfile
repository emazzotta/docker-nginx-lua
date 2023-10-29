FROM --platform=linux/amd64 debian:stable-slim as dependencies

RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    libpcre3-dev \
    uuid-dev \
    wget \
    zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

FROM dependencies as builder

# http://nginx.org/en/download.html
ENV NGINX_VERSION=1.23.1
# https://github.com/simpl/ngx_devel_kit/releases
ENV NGINX_DEV_VERSION=0.3.2
# https://www.openssl.org/source/
ENV OPENSSL_VERSION=1.1.1w
# https://github.com/openresty/headers-more-nginx-module/tags
ENV HEADERS_MORE_VERSION=0.35
# https://github.com/pagespeed/ngx_pagespeed/releases
ENV GOOGLE_PAGESPEED_VERSION=1.14.33.1-RC1
# https://archive.apache.org/dist/incubator/pagespeed/
ENV PAGESPEED_OPTIMISATION_LIBRARY_VERSION=jammy

ENV LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
ENV NGINX_TEMP_DIR=/tmp/nginx
ENV NGINX_DIR=/etc/nginx

ENV NGINX_ACCEPT_LANGUAGE_MODULE_PATH=$NGINX_TEMP_DIR/nginx_accept_language_module-master
ENV NGX_DEV_MODULE_PATH=$NGINX_TEMP_DIR/ngx_devel_kit-$NGINX_DEV_VERSION
ENV OPENSSL_MODULE_PATH=$NGINX_TEMP_DIR/openssl-$OPENSSL_VERSION
ENV HEADERS_MORE_MODULE_PATH=$NGINX_TEMP_DIR/headers-more-nginx-module-$HEADERS_MORE_VERSION
ENV GOOGLE_PAGESPEED_MODULE_PATH=$NGINX_TEMP_DIR/incubator-pagespeed-ngx-$GOOGLE_PAGESPEED_VERSION

RUN mkdir -p $NGINX_TEMP_DIR
RUN mkdir -p $GOOGLE_PAGESPEED_MODULE_PATH
COPY archive/psol-$PAGESPEED_OPTIMISATION_LIBRARY_VERSION.tar.gz $GOOGLE_PAGESPEED_MODULE_PATH

WORKDIR $NGINX_TEMP_DIR

RUN wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
        -P $NGINX_TEMP_DIR/ && \
        tar xzf nginx-$NGINX_VERSION.tar.gz --strip-components=1 && \
        rm -rf nginx-$NGINX_VERSION.tar.gz

RUN wget https://github.com/pagespeed/ngx_pagespeed/archive/v$GOOGLE_PAGESPEED_VERSION.tar.gz \
        -O $GOOGLE_PAGESPEED_MODULE_PATH.tar.gz && \
        tar xzf $GOOGLE_PAGESPEED_MODULE_PATH.tar.gz && \
        cd $GOOGLE_PAGESPEED_MODULE_PATH && \
        tar xzf psol-$PAGESPEED_OPTIMISATION_LIBRARY_VERSION.tar.gz

RUN wget https://github.com/giom/nginx_accept_language_module/archive/master.tar.gz \
        -O $NGINX_ACCEPT_LANGUAGE_MODULE_PATH.tar.gz && \
        tar xzf $NGINX_ACCEPT_LANGUAGE_MODULE_PATH.tar.gz && \
        rm -rf $NGINX_ACCEPT_LANGUAGE_MODULE_PATH.tar.gz

RUN wget https://github.com/simpl/ngx_devel_kit/archive/v$NGINX_DEV_VERSION.tar.gz \
        -O $NGX_DEV_MODULE_PATH.tar.gz && \
        tar xzf $NGX_DEV_MODULE_PATH.tar.gz

RUN wget https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_VERSION.tar.gz \
        -O $HEADERS_MORE_MODULE_PATH.tar.gz && \
        tar xzf $HEADERS_MORE_MODULE_PATH.tar.gz

RUN wget https://openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz \
        -O $OPENSSL_MODULE_PATH.tar.gz && \
        tar xzf $OPENSSL_MODULE_PATH.tar.gz

RUN ./configure \
    --prefix=$NGINX_DIR \
    --add-module=$NGINX_ACCEPT_LANGUAGE_MODULE_PATH \
    --add-module=$GOOGLE_PAGESPEED_MODULE_PATH \
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
    --group=nginx

RUN make
RUN make install

FROM debian:stable-slim

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="hello@mazzotta.me" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Docker Nginx" \
    org.label-schema.description="Docker for Nginx with More Headers and Google Pagespeed preinstalled" \
    org.label-schema.url="https://github.com/emazzotta/docker-nginx-lua" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/emazzotta/docker-nginx-lua" \
    org.label-schema.vendor="Emanuele Mazzotta" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY mime.types /usr/local/nginx/conf/mime.types

RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log && \
    ln -sf /dev/stderr /usr/local/nginx/logs/error.log

WORKDIR /usr/local/nginx

RUN mkdir -p /usr/local/nginx/conf/conf.d

EXPOSE 80 443

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
