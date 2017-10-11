FROM centos:7
MAINTAINER KINGHU88 517834203@qq.com
RUN yum -y install  pcre-devel openssl-devel gcc gcc-c++ make
RUN groupadd nginx && useradd -r -s /sbin/nologin -g nginx nginx
ADD nginx-1.12.1.tar.gz /tmp
RUN cd /tmp/nginx-1.12.1 && ./configure \
--prefix=/usr/local/nginx \ 
--with-http_stub_status_module \ 
--with-http_ssl_module \ 
--with-http_gzip_static_module \ 
--with-pcre && \
make -j 4 && make install

COPY nginx.conf /usr/local/nginx/conf
RUN chown -R nginx.nginx /usr/local/nginx

EXPOSE 80
CMD ["usr/local/nginx/sbin/nginx", "-g", "daemon off;"]