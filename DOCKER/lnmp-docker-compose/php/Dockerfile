FROM centos:7
MAINTAINER KINGHU88 517834203@qq.com
RUN yum -y install gmp-devel libmcrypt-devel libxslt-devel openssl-devel zlib-devel libxml2-devel libjpeg-devel  freetype-devel libpng-devel gd-devel libcurl-devel gcc gcc-c++ make cmake mhash mcrypt
#https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
ADD libiconv-1.15.tar.gz /tmp/
RUN cd /tmp/libiconv-1.15 && ./configure --prefix=/usr/local/libiconv && make && make install

ADD php-7.1.8.tar.gz /tmp/
RUN cd /tmp/php-7.1.8 && \
	./configure --prefix=/usr/local/php \
	--with-iconv-dir=/usr/local/libiconv \
	--with-config-file-path=/usr/local/php/etc \
	--with-jpeg-dir --with-png-dir --with-freetype-dir \
	--with-zlib --with-libxml-dir \
	--with-mcrypt --with-gd --with-curl \
	--with-gmp --with-gettext --with-mhash \
	--with-openssl  --with-xmlrpc --with-pear \
	--enable-bcmath --enable-gd-native-ttf \
	--enable-xml --enable-fpm  --enable-embedded-mysqli \
	--enable-mbstring --enable-inline-optimization --enable-sockets \
	--enable-zip --enable-sysvmsg --enable-sysvsem \
	--enable-sysvshm --enable-soap --enable-ftp \
	--disable-debug --disable-ipv6 --with-mysql --with-mysqli && \
	make -j 4 && make install && \
	cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
#	sed -i "s/127.0.0.1/0.0.0.0/" /usr/local/php/etc/php-fpm.conf && \
	cp /usr/local/php/sbin/php-fpm /etc/init.d/php-fpm && \
	chmod +x /etc/init.d/php-fpm
COPY php.ini /usr/local/php/etc

EXPOSE 9000
CMD /etc/init.d/php-fpm start && tail -F /var/log/messages