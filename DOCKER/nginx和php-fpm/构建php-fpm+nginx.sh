[root@docker-node1 nginx_conf]# tree 
.
├── default.conf
└── wwwroot
    ├── 404.html
    └── index.php

1 directory, 3 files
#配置文件从nginx容器中拷贝出来，目录/etc/nginx/conf.d/
#挂载nginx配置文件（default.conf）到容器：-v /root/nginx_conf:/etc/nginx/conf.d
#挂载nginx网站目录到容器：-v /root/nginx_conf/wwwroot:/usr/share/nginx/html
#挂载php网站目录到容器：-v /root/nginx_conf/wwwroot:/var/www/html
#link：php，nginx配置文件要用


#取消这段的注释，并修改如下
location ~ \.php$ {
        fastcgi_pass   php:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /var/www/html/$fastcgi_script_name;
        include        fastcgi_params;
    }


docker run -d -p 80:80 --name mynginx --link myfpm:php \
-v /root/nginx_conf:/etc/nginx/conf.d \
-v /root/nginx_conf/wwwroot:/usr/share/nginx/html nginx

docker run -d -p 9000:9000 --name myfpm \
-v /root/nginx_conf/wwwroot:/var/www/html php:7.0-fpm