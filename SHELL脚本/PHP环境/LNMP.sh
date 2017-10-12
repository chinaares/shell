function NGINX-INSTALL(){
    printf "%1s \033[1;32m nginx start installing... \033[0m \n"
    groupadd www && useradd -r -s /sbin/nologin -g www www
    yum -y install pcre pcre-devel openssl openssl-devel gd gd-devel perl perl-ExtUtils-Embed
    cd /app && tar -xzf $Ngx_path.tar.gz -C /usr/local/ && tar -xzf ${NGINX}.tar.gz -C /usr/src/
    #wget http://nginx.org/download/${NGINX}.tar.gz  

    cd /usr/src/${NGINX}/
    ./configure --prefix=/usr/local/nginx --add-module=/usr/local/$Ngx_path \
    --user=www --group=www --with-http_gzip_static_module \
    --with-http_stub_status_module  --with-http_ssl_module \
    --with-http_realip_module --with-http_addition_module \
    --with-http_dav_module --with-http_perl_module --with-http_flv_module
    if [ $? != 0 ]
    then
        printf "%1s \033[1;32m NGINX 编译失败！ \033[0m \n"
        exit 1
    else
        printf "%1s \033[1;32m NGINX 编译成功！！ \033[0m \n"
        make -j 4 && make install
    fi
    chown -R www.www /usr/local/nginx && mkdir /tmp/tcmalloc && chmod 0777 /tmp/tcmalloc
    mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
    cat > /usr/local/nginx/conf/nginx.conf << "EOF"
    user  www www; 
    worker_processes  2; 
    worker_rlimit_nofile 65535;  
    error_log  logs/error.log  notice;
    pid        logs/nginx.pid;
    events {
        use epoll; 
        worker_connections  1024;  
        multi_accept on;
    }
    http {
        include       mime.types;
        default_type  application/octet-stream;
        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                          '$status $body_bytes_sent "$http_referer" '
                          '"$http_user_agent" "$http_x_forwarded_for"';
        access_log  logs/access.log  main;
        sendfile        on;
        tcp_nopush     on;
        tcp_nodelay   on;
        keepalive_timeout  60;
        client_header_timeout 10;
        client_body_timeout 10;
        send_timeout 20;
        client_max_body_size 30m;
    ############################################
        gzip on;
        gzip_min_length 1k;
        gzip_buffers 8 64k;
        gzip_http_version 1.1;
        gzip_comp_level 4;
        gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/x-httpd-php
        gzip_vary on;
    #############################################    
        server {
            listen       80;
            server_name  localhost;
            charset utf-8;
            access_log  logs/localhost.access.log  main;
            location / {
                root   html;
                index  index.php  index.html index.htm;
            }

            error_page  404              /404.html;
            error_page   500 502 503 504  /50x.html;
            location = /50x.html {
                root   html;
            }
            location ~ \.php$ {
                #root           html;
                fastcgi_pass   127.0.0.1:9000;
                fastcgi_index  index.php;
                fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include        fastcgi_params;
            }
        }
    }
    EOF
    chown www.www /usr/local/nginx/conf/nginx.conf && echo "/usr/local/nginx/sbin/nginx" >> /etc/rc.d/rc.local
    rm -rf /usr/local/nginx/html/index.html
    echo "<?php phpinfo();?>" > /usr/local/nginx/html/index.php
}

function MYSQL-INSTALL(){
    rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
    yum -y install mysql-server mysql mysql-devel
    chown -R root:root /var/lib/mysql
}

function PHP-INSTALL(){
    #################################一、libmcrypt package#################################
    printf "%1s \033[1;32m libmcrypt安装... \033[0m \n"
    #wget ftp://mcrypt.hellug.gr/pub/crypto/mcrypt/libmcrypt/${LibmCrypt}.tar.gz
    cd /app && tar -zxvf ${LibmCrypt}.tar.gz -C /usr/src/ && cd /usr/src/${LibmCrypt}
    ./configure --prefix=/usr/local/ && make -j 4 && make install
    if [ $? != 0 ]
    then
        printf "%1s \033[1;32m Libmcrypt安装失败！！ \033[0m \n"
        exit 1
    else
        printf "%1s \033[1;32m Libmcrypt安装成功！！ \033[0m \n"
        echo "/usr/local/lib" >> /etc/ld.so.conf && /sbin/ldconfig
    fi

    #################################Llibiconv package#################################
    printf "%1s \033[1;32m Llibiconv安装... \033[0m \n"
    cd /app && tar zxf ${Llibiconv_path}.tar.gz -C /usr/src/ && cd /usr/src/${Llibiconv_path}
    ./configure --prefix=/usr/local/libiconv
    if [ $? != 0 ]
    then
        printf "%1s \033[1;32m libiconv 编译失败！ \033[0m \n"
        exit 1
    else
        printf "%1s \033[1;32m libiconv 编译成功！！ \033[0m \n"
        make -j 4 && make install
    fi

    #################################三、PHP7 package#################################
    printf "%1s \033[1;32m PHP7安装开始... \033[0m \n"
    yum install -y gmp-devel libmcrypt-devel libxslt-devel \
    openssl-devel zlib-devel libxml2-devel \
    libjpeg-devel  freetype-devel libpng-devel \
    gd-devel libcurl-devel 

    cd /app && tar -xzf ${PHP}.tar.gz -C /usr/src/ && cd /usr/src/${PHP}
    ./configure --prefix=/usr/local/php --with-iconv-dir=/usr/local/libiconv \
    --with-jpeg-dir --with-png-dir --with-freetype-dir  \
    --with-zlib  --with-libxml-dir --with-mcrypt --with-gd \
    --with-curl --with-gmp --with-gettext --with-mhash \
    --with-openssl  --with-xmlrpc --with-pear  --enable-bcmath \
    --enable-gd-native-ttf --enable-xml --enable-fpm  \
    --enable-embedded-mysqli --enable-mbstring \
    --enable-inline-optimization --enable-sockets \
    --enable-zip --enable-sysvmsg --enable-sysvsem \
    --enable-sysvshm --enable-soap --enable-ftp \
    --disable-debug --disable-ipv6 \
    --with-mysql --with-mysqli
    if [ $? != 0 ]
    then
        printf "%1s \033[1;32m PHP编译失败！！ \033[0m \n"
        exit 1
    else
        printf "%1s \033[1;32m PHP编译成功！！ \033[0m \n"
        make -j 4 && make install
    fi

    cd /usr/src/${PHP} && cp -r php.ini-development /usr/local/php/lib/php.ini && chown -R www.www /usr/local/php
    cp -r /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf 
    #set 【;listen.owner = nobody】【;listen.group = nobody】为 【listen.owner = www】【listen.group = www】
    sed -i '/user = nobody/c user = www' /usr/local/php/etc/php-fpm.conf
    sed -i '/group = nobody/c group = www' /usr/local/php/etc/php-fpm.conf
    sed -i '/;listen.group = nobody/a listen.group = www\nlisten.owner = www' /usr/local/php/etc/php-fpm.conf
    #set 【;date.timezone =】 to 【date.timezone = Asia/Shanghai  or  PRC 】
    sed -i '/;date.timezone =/a date.timezone = Asia/Shanghai' /usr/local/php/lib/php.ini
    #------------------------------------------------------------------------
    echo "/usr/local/php/sbin/php-fpm" >> /etc/rc.d/rc.local
}