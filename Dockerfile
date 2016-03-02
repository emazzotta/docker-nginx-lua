FROM debian:jessie

MAINTAINER Emanuele Mazzotta <hello@mazzotta.me>

ENV NGINX_VERSION=1.9.10
ENV OPENSSL_VERSION=1.0.2g
ENV LUA_JIT_VERSION=2.0.4
ENV LUA_VERSION=0.10.0
ENV NGINX_DEV_VERSION=0.2.19
ENV HEADERS_MORE_VERSION=0.261

ENV NGINX_TEMP_DIR=/usr/src/nginx
ENV NGINX_DIR=/etc/nginx
ENV GH=https://github.com

ENV HEADERS_MORE=$NGINX_TEMP_DIR/headers-more-nginx-module-$HEADERS_MORE_VERSION
ENV NGX_DEV=$NGINX_TEMP_DIR/ngx_devel_kit-$NGINX_DEV_VERSION
ENV LUA_MOD=$NGINX_TEMP_DIR/lua-nginx-module-$LUA_VERSION

ENV LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH

RUN apt-get update && apt-get install -qqy \ 
    wget \
    build-essential \
    linux-kernel-headers \
    libpcre3 \
    libpcre3-dev \
    zlib1g-dev

RUN mkdir -p $NGINX_TEMP_DIR
WORKDIR $NGINX_TEMP_DIR

RUN wget http://luajit.org/download/LuaJIT-$LUA_JIT_VERSION.tar.gz && \
    tar xzvf LuaJIT-$LUA_JIT_VERSION.tar.gz && \
    cd $NGINX_TEMP_DIR/LuaJIT-$LUA_JIT_VERSION && \
    make && make install

RUN wget https://openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz \
    -P $NGINX_TEMP_DIR/ && \
    tar xzvf openssl-$OPENSSL_VERSION.tar.gz

RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    -P $NGINX_TEMP_DIR/ && \
    tar xzvf nginx-$NGINX_VERSION.tar.gz --strip-components=1

RUN wget $GH/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_VERSION.tar.gz \
    -O headers-more-nginx-module-v$HEADERS_MORE_VERSION.tar.gz && \
    tar xzvf headers-more-nginx-module-v$HEADERS_MORE_VERSION.tar.gz

RUN wget $GH/simpl/ngx_devel_kit/archive/v$NGINX_DEV_VERSION.tar.gz \
    -O ngx_devel_kit-v$NGINX_DEV_VERSION.tar.gz && \
    tar xzvf ngx_devel_kit-v$NGINX_DEV_VERSION.tar.gz

RUN wget $GH/chaoslawful/lua-nginx-module/archive/v$LUA_VERSION.tar.gz && \
    tar xzvf v$LUA_VERSION.tar.gz

RUN ./configure \
 --prefix=$NGINX_DIR \
 --add-module=$HEADERS_MORE \
 --add-module=$NGX_DEV \
 --add-module=$LUA_MOD \
 --with-openssl=$NGINX_TEMP_DIR/openssl-$OPENSSL_VERSION \
 --with-ipv6 \
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

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
