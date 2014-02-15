server {
       listen 80;
       server_name cloud.gwynprice.com;
       root /opt/www/cloud.gwynprice.com;

       access_log /var/log/nginx/cloud.gwynprice.com.access.log;
      error_log /var/log/nginx/cloud.gwynprice.com.error.log;

       if ($http_host != "cloud.gwynprice.com") {
                 rewrite ^ http://cloud.gwynprice.com$request_uri permanent;
       }

       index index.php index.html;

       location = /favicon.ico {
                log_not_found off;
                access_log off;
       }

       location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
       }

       # Deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
       location ~ /\. {
                deny all;
                access_log off;
                log_not_found off;
       }

        client_max_body_size 10G; # set max upload size

        rewrite ^/caldav(.*)$ /remote.php/caldav$1 redirect;
        rewrite ^/carddav(.*)$ /remote.php/carddav$1 redirect;
        rewrite ^/webdav(.*)$ /remote.php/webdav$1 redirect;
        rewrite ^/apps/calendar/caldav.php /remote.php/caldav/ last;
        rewrite ^/apps/contacts/carddav.php /remote.php/carddav/ last;
        rewrite ^/apps/([^/]*)/(.*\.(css|php))$ /index.php?app=$1&getfile=$2 last;
        rewrite ^/remote/(.*) /remote.php last;

        error_page 403 = /core/templates/403.php;
        error_page 404 = /core/templates/404.php;

        location ~ ^/(data|config|\.ht|db_structure\.xml|README) {
                        deny all;
        }

        location / {
                        rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
                        rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;

                        rewrite ^/.well-known/carddav /remote.php/carddav/ redirect;
                        rewrite ^/.well-known/caldav /remote.php/caldav/ redirect;

                        rewrite ^(/core/doc/[^\/]+/)$ $1/index.html;

                        try_files $uri $uri/ /index.php$is_args$args;
        }

        location ~ ^(.+?\.php)(/.*)?$ {
                        try_files $1 =404;
                        include fastcgi_params;
                        fastcgi_param SCRIPT_FILENAME $document_root$1;
                        fastcgi_param PATH_INFO $2;
                        fastcgi_param HTTPS $https;
                        fastcgi_pass unix:/var/run/php5-fpm.sock;
                        fastcgi_intercept_errors on;
                        fastcgi_index index.php;
                        fastcgi_buffers 64 4K;
        }

        location ~* ^.+\.(jpg|jpeg|gif|bmp|ico|png|css|js|swf)$ {
                        expires 30d;
                        access_log off;
        }
}