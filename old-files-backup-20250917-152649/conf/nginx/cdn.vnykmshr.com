server {
    server_name cdn.vnykmshr.com;
    root /Users/vm/workspace/vnykmshr/public;
    index index.html index.htm;

    location / {
	try_files $uri $uri/ @proxy;
        add_header Cache-Control public;
        expires 2w;
    }

    location @proxy {
       proxy_pass   http://www.vnykmshr.com;
    }
}

