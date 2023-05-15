#!/usr/bin/env bash

echo ' ### NGINX.SH ### '

function install_nginx() {
  # Install dependencies
  update-rc.d sendmail disable
  apt install -y linux-generic
  apt update -y && apt upgrade -y
  apt install -y git
  apt install mercurial libpcre3 libpcre3-dev gcc make autoconf zlib1g zlib1g-dev -y

  # clone nginx build module
  git clone https://github.com/google/ngx_brotli.git

  # download and install openssl+quick
  git clone --depth 1 -b openssl-3.0.5+quic https://github.com/quictls/openssl
  cd openssl &&
    ./config enable-tls1_3 --prefix="$PWD/build"
  make -j "$(nproc)"
  make install_sw
  cd ..

  # install golang
  apt install -y software-properties-common
  add-apt-repository -y ppa:longsleep/golang-backports
  apt -y update && apt -y upgrade
  apt install -y golang-go
  apt -y update && apt -y upgrade

  # Perform to install boringssl
  apt update &&
    apt install -y git gcc make g++ cmake perl libunwind-dev &&
    git clone https://boringssl.googlesource.com/boringssl &&
    mkdir boringssl/build &&
    cd boringssl/build &&
    cmake .. &&
    make
  cd ../..

  # Install nginx itself + the brotli module + openssl+quik
  # shellcheck disable=SC2006,SC2046
  apt-get install -y mercurial libperl-dev libpcre3-dev zlib1g-dev libxslt1-dev libgd-ocaml-dev libgeoip-dev &&
    hg clone -b quic https://hg.nginx.org/nginx-quic &&
    hg clone http://hg.nginx.org/njs -r "0.6.2" &&
    git submodule update --init &&
    cd nginx-quic &&
    hg update quic &&
    auto/configure $(nginx -V 2>&1 | sed "s/ \-\-/ \\ \n\t--/g" | grep "\-\-" | grep -ve opt= -e param= -e build=) \
      --prefix=/etc/nginx \
      --sbin-path=/usr/sbin/nginx \
      --with-openssl=../openssl \
      --conf-path=/etc/nginx/nginx.conf \
      --http-log-path=/var/log/nginx/access.log \
      --error-log-path=/var/log/nginx/error.log \
      --with-pcre \
      --lock-path=/var/lock/nginx.lock \
      --pid-path=/var/run/nginx.pid \
      --with-http_ssl_module \
      --with-http_image_filter_module=dynamic \
      --modules-path=/etc/nginx/modules \
      --with-http_v2_module \
      --with-stream=dynamic \
      --with-http_addition_module \
      --with-http_mp4_module \
      --add-module=../ngx_brotli \
      --build=nginx-quic --with-debug \
      --with-http_v3_module --with-stream_quic_module \
      --with-cc-opt="-I/src/boringssl/include" --with-ld-opt="-L/src/boringssl/build/ssl -L/src/boringssl/build/crypto" &&
    make && make install
}

echo "Compiling nginx from sorces. This may take a while..."

# shellcheck disable=SC2154
ssh "$sshstr" 'bash -s' < <(
  typeset -f install_nginx
  echo "install_nginx"
)

# shellcheck disable=SC2181
if [[ $? -eq 0 ]]; then
  echo "Nginx installed successfully"
else
  echo "Nginx installation failed"
fi
