FROM ubuntu:14.04

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y wget git unzip && \
  rm -rf /var/lib/apt/lists/*

ENV NPS_VERSION 1.10.33.4

ENV NGINX 1.11.1

RUN \
  mkdir ~/sources && \
  #cd ~/sources && \
  #wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip -O release-${NPS_VERSION}-beta.zip && \
  #unzip release-${NPS_VERSION}-beta.zip && \ 
  #cd ~/sources/ngx_pagespeed-release-${NPS_VERSION}-beta/ && \ 
  #wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \ 
  #tar -xzvf ${NPS_VERSION}.tar.gz && \
  cd ~/sources && \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y libpcre3-dev libpcrecpp0 libssl-dev zlib1g-dev && \
  rm -rf /var/lib/apt/lists/* && \
  wget http://nginx.org/download/nginx-$NGINX.tar.gz && \
  tar -zxvf nginx-$NGINX.tar.gz && \
  git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng.git && \
  cd nginx-$NGINX && \
  ./configure \
    --prefix=/etc/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/sbin/nginx \
    --pid-path=/var/log/nginx/nginx.pid \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-http_ssl_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-ipv6 \
    --with-http_v2_module \
    --add-module=/root/sources/nginx-sticky-module-ng && \
    # --add-module=/root/sources/ngx_pagespeed-release-${NPS_VERSION}-beta ${PS_NGX_EXTRA_FLAGS} && \
  make && \
  make install && \
  rm -rf ~/sources

RUN useradd nginx

VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx"]

WORKDIR /etc/nginx

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

EXPOSE 80 443
