FROM debian:jessie

MAINTAINER Emanuele Mazzotta <hello@mazzotta.me>

ENV NGINX_VERSION=nginx-1.9.10
ENV OPENSSL_VERSION=openssl-1.0.2f

RUN mkdir -p /usr/src/nginx
WORKDIR /usr/src/nginx

RUN apt-get update \
    && apt-get install -y wget \
    && apt-get install -y git \
    && apt-get install -y build-essential \
    && apt-get install -y linux-kernel-headers \
    && apt-get install -y libpcre3 \
    && apt-get install -y libpcre3-dev \
    && apt-get install zlib1g-dev

RUN wget http://www.openssl.org/source/$OPENSSL_VERSION.tar.gz -P /usr/src/nginx/
RUN tar xvzf $OPENSSL_VERSION.tar.gz

RUN wget http://nginx.org/download/$NGINX_VERSION.tar.gz -P /usr/src/nginx/
RUN tar xvzf $NGINX_VERSION.tar.gz --strip-components=1

RUN git clone https://github.com/openresty/headers-more-nginx-module.git /usr/src/nginx/headers-more-nginx-module

RUN ./configure --prefix=/etc/nginx --add-module=/usr/src/nginx/headers-more-nginx-module --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --with-http_v2_module --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-mail --with-mail_ssl_module --with-file-aio --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security' --with-ld-opt=-Wl,-z,relro --with-ipv6 --with-openssl=/usr/src/nginx/$OPENSSL_VERSION
RUN make && make install

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
