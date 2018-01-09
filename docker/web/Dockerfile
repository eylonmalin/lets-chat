FROM nginx:stable

RUN rm /etc/nginx/conf.d/default.conf

COPY docker/web/assets/* /var/lib/nginx/lets-chat/
COPY media /var/lib/nginx/lets-chat/media

# Add and setup entrypoint
COPY docker/web/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

