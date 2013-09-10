
server {
	listen 80;

	root /opt/www/gwynprice;
	index index.html index.php;

	# Make site accessible from http://localhost/
	server_name gwynprice.com www.gwynprice.com *.gwynprice.com;

	access_log /var/log/nginx/www.gwynprice.com.access.log;
	error_log /var/log/nginx/www.gwynprice.com.error.log;

 	location / {
               try_files $uri $uri/ /index.php?$args;
       }

	
	# w3 cache stuff
	# Set a variable to work around the lack of nested conditionals


#cache static files for as long as possible
location ~* \.(xml|ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|css|rss|atom|js|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
try_files $uri =404;
expires max;
access_log off;
}
# Deny access to hidden files
location ~* /\.ht {
deny all;
access_log off;
log_not_found off;
}


	# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	#
	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		# NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
	
		# With php5-cgi alone:
		#fastcgi_pass 127.0.0.1:9000;
		# With php5-fpm:
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		include fastcgi_params;
	}

}
