server {
    server_name cdn.urbantou.ch;
    root /home/bmishra/source/nodestore/public;
    index index.html index.htm;

    location / {
	try_files $uri $uri/ @proxy;
        add_header Cache-Control public;
        expires 2w;
    }

    location @proxy {
       proxy_pass   http://cdn1.urbantouch.com;
    }
}

