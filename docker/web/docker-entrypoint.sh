#!/bin/sh

echo 
echo

echo "                                                ───▄▀▀▀▄▄▄▄▄▄▄▀▀▀▄───"
echo "                                                ───█▒▒░░░░░░░░░▒▒█───"
echo "                                                ────█░░█░░░░░█░░█────"
echo "                                                ─▄▄──█░░░▀█▀░░░█──▄▄─"
echo "                                                █░░█─▀▄░░░░░░░▄▀─█░░█"
echo "                                                █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█"
echo "                                                █░░╦─╦╔╗╦─╔╗╔╗╔╦╗╔╗░░█"
echo "                                                █░░║║║╠─║─║─║║║║║╠─░░█"
echo "                                                █░░╚╩╝╚╝╚╝╚╝╚╝╩─╩╚╝░░█"
echo "                                                ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"
echo " ██╗      ███████╗ ████████╗ ███████╗      ██████╗ ██╗  ██╗  █████╗  ████████╗     ██╗    ██╗ ███████╗ ██████╗  "
echo " ██║      ██╔════╝ ╚══██╔══╝ ██╔════╝     ██╔════╝ ██║  ██║ ██╔══██╗ ╚══██╔══╝     ██║    ██║ ██╔════╝ ██╔══██╗ "
echo " ██║      █████╗      ██║    ███████╗     ██║      ███████║ ███████║    ██║        ██║ █╗ ██║ █████╗   ██████╔╝ "
echo " ██║      ██╔══╝      ██║    ╚════██║     ██║      ██╔══██║ ██╔══██║    ██║        ██║███╗██║ ██╔══╝   ██╔══██╗ "
echo " ███████╗ ███████╗    ██║    ███████║     ╚██████╗ ██║  ██║ ██║  ██║    ██║        ╚███╔███╔╝ ███████╗ ██████╔╝ "
echo " ╚══════╝ ╚══════╝    ╚═╝    ╚══════╝      ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝    ╚═╝         ╚══╝╚══╝  ╚══════╝ ╚═════╝  "

echo
echo

echo " ██╗   ██╗ ██████╗  "
echo " ██║   ██║ ╚════██╗ "
echo " ██║   ██║  █████╔╝ "
echo " ╚██╗ ██╔╝ ██╔═══╝  "
echo "  ╚████╔╝  ███████╗ "
echo "   ╚═══╝   ╚══════╝ "


# echo " ██╗   ██╗  ██╗ "
# echo " ██║   ██║ ███║ "
# echo " ██║   ██║ ╚██║ "
# echo " ╚██╗ ██╔╝  ██║ "
# echo "  ╚████╔╝   ██║ "
# echo "   ╚═══╝    ╚═╝ "

echo
echo

# Define default value for app container hostname and port
APP_HOST=${APP_HOST:-localhost}
APP_PORT=${APP_PORT:-8080}
CODE_ENABLED=${CODE_ENABLED:-true}
THE_CODE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1 | tr '[:upper:]' '[:lower:]')

mkdir -p /etc/lets-chat

echo "${THE_CODE}" > /etc/lets-chat/code.txt

render_rules_with_the_code(){
  cat > /etc/nginx/conf.d/lets-chat.conf <<EOF
upstream lets_chat {
  server ${APP_HOST}:${APP_PORT};
}

server {
  listen 80 default_server;
  listen [::]:80 default_server;
  #server_name 172.17.0.7;     # e.g., server_name source.example.com;
  server_tokens off;     # don't show the version number, a security best practice
  
  # Increase this if you want to upload large attachments
  # Or if you want to accept large git objects over http
  client_max_body_size 20m;

  # individual nginx logs for this letschat vhost
  access_log  /var/log/nginx/letschat/letschat.log;
  error_log   /var/log/nginx/letschat/letschat.log info;
  root /var/lib/nginx/lets-chat;

  location =/ {
    index  /index.html;
  }

  location /auth-code {
    if ( \$arg_code = "${THE_CODE}" ) { rewrite ^(/auth-code).*\$ /good-code.html last; }

    # do the remaining stuff
  	rewrite ^(/auth-code).*\$ /bad-code.html last;
  }
  
  location / {

    # serve static files from defined root folder;.
    # @lets_chat is a named location for the upstream fallback, see below
    try_files \$uri \$uri.html @lets_chat;
  }

  # if a file, which is not found in the root folder is requested,
  # then the proxy pass the request to the upsteam (gitlab unicorn)
  location @lets_chat {
  	gzip on;
      
    proxy_redirect     off;

    proxy_set_header   X-Forwarded-Proto \$scheme;
    proxy_set_header   Host              \$http_host;
    proxy_set_header   X-Real-IP         \$remote_addr;
    proxy_set_header   X-Forwarded-For  \$proxy_add_x_forwarded_for;
    proxy_set_header   X-Frame-Options   SAMEORIGIN;

    proxy_pass http://lets_chat;
  }

  error_page 500 501 502 503 504 /500.html;
}
EOF


}

render_rules(){
	cat > /etc/nginx/conf.d/lets-chat.conf <<EOF
upstream lets_chat {
  server ${APP_HOST}:${APP_PORT};
}

server {
  listen 80 default_server;
  listen [::]:80 default_server;
  #server_name ${APP_HOST};     # e.g., server_name source.example.com;
  server_tokens off;     # don't show the version number, a security best practice
  root /dev/null;
  
  # Increase this if you want to upload large attachments
  # Or if you want to accept large git objects over http
  client_max_body_size 20m;

  # individual nginx logs for this gitlab vhost
  access_log  /var/log/nginx/letschat/letschat.log;
  error_log   /var/log/nginx/letschat/letschat.log info;

  location / {
    root /var/lib/nginx/lets-chat;
    # serve static files from defined root folder;.
    # @lets_chat is a named location for the upstream fallback, see below
    try_files \$uri \$uri.html @lets_chat;
  }

  # if a file, which is not found in the root folder is requested,
  # then the proxy pass the request to the upsteam (gitlab unicorn)
  location @lets_chat {
  	gzip on;

  	proxy_redirect     off;
        
    proxy_set_header   X-Forwarded-Proto \$scheme;
    proxy_set_header   Host              \$http_host;
    proxy_set_header   X-Real-IP         \$remote_addr;
    proxy_set_header   X-Forwarded-For  \$proxy_add_x_forwarded_for;
    proxy_set_header   X-Frame-Options   SAMEORIGIN;

    proxy_pass http://lets_chat;
  }

  error_page 500 501 502 503 504 /500.html;
}
EOF

}


if [ "${CODE_ENABLED}" != "true" ]; then
	render_rules
else
	render_rules_with_the_code
fi

sed -i "s/{%HOSTNAME%}/${HOSTNAME}/g" /var/lib/nginx/lets-chat/index.html
sed -i "s/{%HOSTNAME%}/${HOSTNAME}/g" /var/lib/nginx/lets-chat/bad-code.html

mkdir -p /var/log/nginx/letschat
touch /var/log/nginx/letschat/letschat.log
tail -f /var/log/nginx/letschat/letschat.log &
# Run Nginx
nginx -g 'daemon off;'