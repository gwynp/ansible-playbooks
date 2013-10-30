
server {
	listen 80;

	root /opt/www/sportdocs;
	index index.html index.php;

	# Make site accessible from http://localhost/
	server_name taofolinux.com www.taooflinux.com *.taooflinux.com;

	access_log /var/log/nginx/www.taooflinux.com.access.log;
	error_log /var/log/nginx/www.taooflinux.com.error.log;

 	location / {
               try_files $uri $uri/ /index.php?$args;
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
