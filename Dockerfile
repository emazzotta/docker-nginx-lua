FROM debian:stable-slim AS builder

RUN apt-get -qq update && apt-get install -qqy --no-install-recommends \
    build-essential \
    ca-certificates \
    libpcre2-dev \
    wget \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

ENV NGINX_TEMP_DIR=/tmp/nginx
ENV NGINX_DIR=/etc/nginx

# http://nginx.org/en/download.html
ENV NGINX_VERSION=1.26.2
# https://github.com/vision5/ngx_devel_kit/releases
ENV NGINX_DEV_VERSION=0.3.3
# https://www.openssl.org/source/
ENV OPENSSL_VERSION=3.0.14
# https://github.com/openresty/headers-more-nginx-module/tags
ENV HEADERS_MORE_VERSION=0.37
# https://github.com/openresty/luajit2/tags
ENV LUAJIT_VERSION=2.1-20231117
# https://github.com/openresty/lua-nginx-module/tags
ENV LUA_NGX_VERSION=0.10.26
# https://github.com/openresty/lua-resty-core/tags
ENV LUA_RESTY_CORE_VERSION=0.1.28
# https://github.com/openresty/lua-resty-lrucache/tags
ENV LUA_RESTY_LRUCACHE_VERSION=0.13

ENV NGINX_ACCEPT_LANGUAGE_MODULE_PATH=$NGINX_TEMP_DIR/nginx_accept_language_module-master
ENV NGX_DEV_MODULE_PATH=$NGINX_TEMP_DIR/ngx_devel_kit-$NGINX_DEV_VERSION
ENV OPENSSL_MODULE_PATH=$NGINX_TEMP_DIR/openssl-$OPENSSL_VERSION
ENV HEADERS_MORE_MODULE_PATH=$NGINX_TEMP_DIR/headers-more-nginx-module-$HEADERS_MORE_VERSION
ENV LUAJIT_PATH=$NGINX_TEMP_DIR/luajit2-$LUAJIT_VERSION
ENV LUA_NGX_MODULE_PATH=$NGINX_TEMP_DIR/lua-nginx-module-$LUA_NGX_VERSION
ENV LUA_RESTY_CORE_PATH=$NGINX_TEMP_DIR/lua-resty-core-$LUA_RESTY_CORE_VERSION
ENV LUA_RESTY_LRUCACHE_PATH=$NGINX_TEMP_DIR/lua-resty-lrucache-$LUA_RESTY_LRUCACHE_VERSION

ENV LUAJIT_LIB=/usr/local/lib
ENV LUAJIT_INC=/usr/local/include/luajit-2.1

RUN mkdir -p $NGINX_TEMP_DIR
WORKDIR $NGINX_TEMP_DIR

RUN wget -q http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
        -P $NGINX_TEMP_DIR/ && \
        tar xzf nginx-$NGINX_VERSION.tar.gz --strip-components=1 && \
        rm -f nginx-$NGINX_VERSION.tar.gz

RUN wget -q https://github.com/giom/nginx_accept_language_module/archive/master.tar.gz \
        -O $NGINX_ACCEPT_LANGUAGE_MODULE_PATH.tar.gz && \
        tar xzf $NGINX_ACCEPT_LANGUAGE_MODULE_PATH.tar.gz && \
        rm -f $NGINX_ACCEPT_LANGUAGE_MODULE_PATH.tar.gz

RUN wget -q https://github.com/simpl/ngx_devel_kit/archive/v$NGINX_DEV_VERSION.tar.gz \
        -O $NGX_DEV_MODULE_PATH.tar.gz && \
        tar xzf $NGX_DEV_MODULE_PATH.tar.gz && \
        rm -f $NGX_DEV_MODULE_PATH.tar.gz

RUN wget -q https://github.com/openresty/headers-more-nginx-module/archive/v$HEADERS_MORE_VERSION.tar.gz \
        -O $HEADERS_MORE_MODULE_PATH.tar.gz && \
        tar xzf $HEADERS_MORE_MODULE_PATH.tar.gz && \
        rm -f $HEADERS_MORE_MODULE_PATH.tar.gz

RUN wget -q https://openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz \
        -O $OPENSSL_MODULE_PATH.tar.gz && \
        tar xzf $OPENSSL_MODULE_PATH.tar.gz && \
        rm -f $OPENSSL_MODULE_PATH.tar.gz

RUN wget -q https://github.com/openresty/luajit2/archive/v$LUAJIT_VERSION.tar.gz \
        -O $LUAJIT_PATH.tar.gz && \
        tar xzf $LUAJIT_PATH.tar.gz && \
        rm -f $LUAJIT_PATH.tar.gz

RUN wget -q https://github.com/openresty/lua-nginx-module/archive/v$LUA_NGX_VERSION.tar.gz \
        -O $LUA_NGX_MODULE_PATH.tar.gz && \
        tar xzf $LUA_NGX_MODULE_PATH.tar.gz && \
        rm -f $LUA_NGX_MODULE_PATH.tar.gz

RUN wget -q https://github.com/openresty/lua-resty-core/archive/v$LUA_RESTY_CORE_VERSION.tar.gz \
        -O $LUA_RESTY_CORE_PATH.tar.gz && \
        tar xzf $LUA_RESTY_CORE_PATH.tar.gz && \
        rm -f $LUA_RESTY_CORE_PATH.tar.gz

RUN wget -q https://github.com/openresty/lua-resty-lrucache/archive/v$LUA_RESTY_LRUCACHE_VERSION.tar.gz \
        -O $LUA_RESTY_LRUCACHE_PATH.tar.gz && \
        tar xzf $LUA_RESTY_LRUCACHE_PATH.tar.gz && \
        rm -f $LUA_RESTY_LRUCACHE_PATH.tar.gz

RUN cd $LUAJIT_PATH && make && make install && ldconfig

RUN ./configure \
        --prefix=$NGINX_DIR \
        --add-module=$NGINX_ACCEPT_LANGUAGE_MODULE_PATH \
        --add-module=$NGX_DEV_MODULE_PATH \
        --add-module=$HEADERS_MORE_MODULE_PATH \
        --add-module=$LUA_NGX_MODULE_PATH \
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
        --with-ld-opt='-Wl,-z,relro -Wl,-rpath,/usr/local/lib' \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/run/nginx.pid \
        --lock-path=/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx && \
        make && \
        make install

RUN make -C $LUA_RESTY_CORE_PATH install \
        PREFIX=/usr/local \
        LUA_LIB_DIR=/usr/local/share/lua/5.1 && \
    make -C $LUA_RESTY_LRUCACHE_PATH install \
        PREFIX=/usr/local \
        LUA_LIB_DIR=/usr/local/share/lua/5.1

RUN rm -rf /tmp/nginx


FROM debian:stable-slim

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="hello@mazzotta.me" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Docker Nginx Lua" \
    org.label-schema.description="Docker for Nginx with LuaJIT and More Headers module preinstalled" \
    org.label-schema.url="https://github.com/emazzotta/docker-nginx-lua" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/emazzotta/docker-nginx-lua" \
    org.label-schema.vendor="Emanuele Mazzotta" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="2.0"

RUN apt-get -qq update && apt-get install -qqy --no-install-recommends \
    libpcre2-8-0 \
    zlib1g && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/local/lib/libluajit-5.1.so* /usr/local/lib/
COPY --from=builder /usr/local/share/lua /usr/local/share/lua

RUN ldconfig && \
    mkdir -p /var/log/nginx /var/cache/nginx /etc/nginx/conf.d && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /etc/nginx

ADD nginx.conf /etc/nginx/nginx.conf
ADD mime.types /etc/nginx/mime.types

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD test -f /run/nginx.pid && kill -0 $(cat /run/nginx.pid) || exit 1

CMD ["nginx", "-g", "daemon off;"]
