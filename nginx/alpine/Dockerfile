FROM alpine:3.9

MAINTAINER ************

COPY nginx-sticky-module /tmp/nginx-sticky-module
COPY nginx_upstream_check_module /tmp/nginx_upstream_check_module
COPY nginx-upstream-fair /tmp/nginx-upstream-fair
COPY nginx-1.6.3 /usr/src/nginx-1.6.3
ADD openssl-1.0.1o.tar.gz /tmp
ADD com.tar.gz /tmp
COPY nginx.conf /tmp

RUN echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > /etc/apk/repositories && \
    echo "http://mirrors.aliyun.com/alpine/latest-stable/community/" >> /etc/apk/repositories
 
RUN apk update && \
    apk add --no-cache ca-certificates && \
    apk add --no-cache curl bash tree tzdata && \
    cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 
ENV NGINX_VERSION 1.6.3
 
RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
    && CONFIG="\
            --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=nginx \
            --group=nginx \
            --http-client-body-temp-path=/etc/nginx/cache/client_body_temp \
            --http-proxy-temp-path=/etc/nginx/cache/proxy_temp \
            --http-fastcgi-temp-path=/etc/nginx/cache/fastcgi_temp \
            --with-file-aio \
            --with-http_spdy_module \
            --with-http_realip_module \
            --with-http_gzip_static_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_stub_status_module \
            --with-http_gzip_static_module \
            --with-ipv6 \
            --with-http_ssl_module \
            --with-openssl=/tmp/openssl-1.0.1o \
            --add-module=/tmp/nginx_upstream_check_module \
            --add-module=/tmp/nginx-upstream-fair \
            --add-module=/tmp/nginx-sticky-module \
            --without-http_ssi_module \
            --without-http_userid_module \
            --without-http_geo_module \
            --without-http_uwsgi_module \
            --without-http_scgi_module \
            --without-mail_pop3_module \
            --without-mail_imap_module \
            --without-mail_smtp_module \
    " \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
#        openssl \
#        openssl-dev \
        pcre \
        pcre-dev \
        zlib-dev \
        linux-headers \
        curl \
        gnupg \
        libxslt-dev \
        gd-dev \
        geoip-dev \
    #&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
    #&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
    #&& export GNUPGHOME="$(mktemp -d)" \
    #&& found=''; \
    #for server in \
     #   ha.pool.sks-keyservers.net \
      #  hkp://keyserver.ubuntu.com:80 \
       # hkp://p80.pool.sks-keyservers.net:80 \
        #pgp.mit.edu \
    #; do \
     #   echo "Fetching GPG key $GPG_KEYS from $server"; \
      #  gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
   # done; \
    #test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
    #gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
   # && rm -r "$GNUPGHOME" nginx.tar.gz.asc \
    && mkdir -p /usr/src \
    && cd /tmp/openssl-1.0.1o && ls -l && ./config && make && mkdir /tmp/openssl-1.0.1o/lib && cp /tmp/openssl-1.0.1o/libc* /tmp/openssl-1.0.1o/lib \
    && cp /tmp/openssl-1.0.1o/libs* /tmp/openssl-1.0.1o/lib \
    && cd /usr/src/nginx-$NGINX_VERSION \
    && ./configure $CONFIG --with-debug \
    && ls -l /usr/src/nginx-$NGINX_VERSION \
    #&& head -10  /usr/src/nginx-$NGINX_VERSION/objs/Makefile \
    && sed -i 's/CFLAGS =  -pipe  -O -W -Wall -Wpointer-arith -Wno-unused -Werror -g/CFLAGS =  -pipe  -O -W -Wall -Wpointer-arith -Wno-unused -g/' /usr/src/nginx-$NGINX_VERSION/objs/Makefile \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && mkdir /etc/nginx/conf.d/ && mkdir -p /etc/nginx/cache/client_body_temp  &&cp /tmp/nginx.conf /etc/nginx/ && cp -r /tmp/common_* /etc/nginx/ \
    && rm -rf /usr/src/nginx-$NGINX_VERSION && rm -rf /tmp/* \
    \
    # Bring in gettext so we can get `envsubst`, then throw
    # the rest away. To do this, we need to install `gettext`
    # then move `envsubst` out of the way so `gettext` can
    # be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .nginx-rundeps $runDeps \
    && apk del .build-deps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
    \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
 
#COPY nginx.conf /etc/nginx/nginx.conf
#COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf
 
EXPOSE 80
STOPSIGNAL SIGTERM
 
CMD ["nginx", "-g", "daemon off;"]
