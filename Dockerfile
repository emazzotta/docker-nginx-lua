FROM debian:jessie

MAINTAINER Emanuele Mazzotta <hello@mazzotta.me>

ENV NGINX_VERSION=1.9.10
ENV OPENSSL_VERSION=1.0.2f
ENV LUA_JIT_VERSION=2.0.4
ENV LUA_VERSION=0.10.0
ENV NGINX_DEV_VERSION=0.2.19
ENV HEADERS_MORE_VERSION=0.261
ENV LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH

RUN apt-get update \
    && apt-get install -y wget \
    build-essential \
    linux-kernel-headers \
    libpcre3 \
    libpcre3-dev \
    zlib1g-dev

RUN mkdir -p /usr/src/nginx
WORKDIR /usr/src/nginx

RUN wget http://luajit.org/download/LuaJIT-$LUA_JIT_VERSION.tar.gz && \
    tar -xzvf LuaJIT-$LUA_JIT_VERSION.tar.gz && \
    cd /usr/src/nginx/LuaJIT-$LUA_JIT_VERSION && \
    make && make install

RUN wget http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz -P /usr/src/nginx/
RUN tar xvzf openssl-$OPENSSL_VERSION.tar.gz

RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -P /usr/src/nginx/
RUN tar xvzf nginx-$NGINX_VERSION.tar.gz --strip-components=1

RUN wget https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_VERSION.tar.gz -O headers-more-nginx-module-v$HEADERS_MORE_VERSION.tar.gz
RUN tar -xzvf headers-more-nginx-module-v$HEADERS_MORE_VERSION.tar.gz
ENV HEADERS_MORE=/usr/src/nginx/headers-more-nginx-module-$HEADERS_MORE_VERSION

RUN wget https://github.com/simpl/ngx_devel_kit/archive/v$NGINX_DEV_VERSION.tar.gz -O ngx_devel_kit-v$NGINX_DEV_VERSION.tar.gz
RUN tar -xzvf ngx_devel_kit-v$NGINX_DEV_VERSION.tar.gz
ENV NGX_DEV=/usr/src/nginx/ngx_devel_kit-$NGINX_DEV_VERSION

RUN wget https://github.com/chaoslawful/lua-nginx-module/archive/v$LUA_VERSION.tar.gz
RUN tar -xzvf v$LUA_VERSION.tar.gz
ENV LUA_MOD=/usr/src/nginx/lua-nginx-module-$LUA_VERSION

RUN ./configure \
 --prefix=/etc/nginx \
 --add-module=$HEADERS_MORE \
 --add-module=$NGX_DEV \
 --add-module=$LUA_MOD \
 --with-openssl=/usr/src/nginx/openssl-$OPENSSL_VERSION \
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

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
