FROM debian:jessie

MAINTAINER Emanuele Mazzotta <hello@mazzotta.me>

RUN apt-get update && apt-get install -qqy \
    wget \
    build-essential \
    linux-kernel-headers \
    libpcre3 \
    libpcre3-dev \
    zlib1g-dev

ENV LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
ENV NGINX_TEMP_DIR=/tmp/nginx
ENV NGINX_DIR=/etc/nginx

ENV NGINX_VERSION=1.13.5
ENV NGINX_DEV_VERSION=0.3.0
ENV LUA_JIT_VERSION=2.0.5
ENV LUA_VERSION=0.10.10
ENV OPENSSL_VERSION=1.0.2l
ENV HEADERS_MORE_VERSION=0.32
ENV GOOGLE_PAGESPEED_VERSION=1.11.33.4-beta
ENV GOOGLE_PAGESPEED_PSOL_VERSION=1.11.33.4

ENV NGX_DEV_MODULE_PATH=$NGINX_TEMP_DIR/ngx_devel_kit-$NGINX_DEV_VERSION
ENV LUAJIT_MODULE_PATH=$NGINX_TEMP_DIR/LuaJIT-$LUA_JIT_VERSION
ENV LUA_MODULE_PATH=$NGINX_TEMP_DIR/lua-nginx-module-$LUA_VERSION
ENV OPENSSL_MODULE_PATH=$NGINX_TEMP_DIR/openssl-$OPENSSL_VERSION
ENV HEADERS_MORE_MODULE_PATH=$NGINX_TEMP_DIR/headers-more-nginx-module-$HEADERS_MORE_VERSION
ENV GOOGLE_PAGESPEED_MODULE_PATH=$NGINX_TEMP_DIR/ngx_pagespeed-$GOOGLE_PAGESPEED_VERSION

RUN mkdir -p $NGINX_TEMP_DIR
WORKDIR $NGINX_TEMP_DIR

### NGINX DOWNLOAD
RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    -P $NGINX_TEMP_DIR/ && \
    tar xzvf nginx-$NGINX_VERSION.tar.gz --strip-components=1

### NGINX DEV DOWNLOAD
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v$NGINX_DEV_VERSION.tar.gz \
   -O ngx_devel_kit-v$NGINX_DEV_VERSION.tar.gz && \
   tar xzvf ngx_devel_kit-v$NGINX_DEV_VERSION.tar.gz

### LUA JIT DOWNLOAD
RUN wget http://luajit.org/download/LuaJIT-$LUA_JIT_VERSION.tar.gz \
    -O $LUAJIT_MODULE_PATH.tar.gz && \
    tar xzvf $LUAJIT_MODULE_PATH.tar.gz && \
    cd $LUAJIT_MODULE_PATH && \
    make && make install

### LUA DOWNLOAD
RUN wget https://github.com/chaoslawful/lua-nginx-module/archive/v$LUA_VERSION.tar.gz \
    -O $LUA_MODULE_PATH.tar.gz && \
    tar xzvf $LUA_MODULE_PATH.tar.gz

### OPENSSL DOWNLOAD
RUN wget https://openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz \
    -O $OPENSSL_MODULE_PATH.tar.gz && \
    tar xzvf $OPENSSL_MODULE_PATH.tar.gz

### MORE HEADERS DOWNLOAD
RUN wget https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_VERSION.tar.gz \
    -O $HEADERS_MORE_MODULE_PATH.tar.gz && \
    tar xzvf $HEADERS_MORE_MODULE_PATH.tar.gz

### GOOGLE PAGESPEED DOWNLOAD
RUN wget https://github.com/pagespeed/ngx_pagespeed/archive/v$GOOGLE_PAGESPEED_VERSION.tar.gz \
    -O $GOOGLE_PAGESPEED_MODULE_PATH.tar.gz && \
    tar xzvf $GOOGLE_PAGESPEED_MODULE_PATH.tar.gz && \
    cd $GOOGLE_PAGESPEED_MODULE_PATH && \
    wget https://dl.google.com/dl/page-speed/psol/$GOOGLE_PAGESPEED_PSOL_VERSION.tar.gz \
    -O psol-$GOOGLE_PAGESPEED_PSOL_VERSION.tar.gz && \
    tar xzvf psol-$GOOGLE_PAGESPEED_PSOL_VERSION.tar.gz

RUN ./configure \
 --prefix=$NGINX_DIR \
 --add-module=$HEADERS_MORE_MODULE_PATH \
 --add-module=$NGX_DEV_MODULE_PATH \
 --add-module=$LUA_MODULE_PATH \
 --add-module=$GOOGLE_PAGESPEED_MODULE_PATH \
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
 --group=nginx && make && make install

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR $NGINX_DIR
RUN rm -rf $NGINX_TEMP_DIR

ADD nginx.conf /etc/nginx/nginx.conf
ADD mime.types /etc/nginx/mime.types
RUN mkdir -p /etc/nginx/conf.d

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
