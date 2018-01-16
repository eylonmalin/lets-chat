FROM sdelements/lets-chat

USER root

ENV MONGO_HOST=mongo \
    MONGO_PORT=27017

COPY docker/app/config.js /usr/src/app/app/config.js
COPY docker/app/app.js /usr/src/app/app.js
COPY docker/app/client.js /usr/src/app/media/js/client.js

RUN npm install socket.io-redis socket.io@^2.0.0

RUN sed 's|nsp.server.encoder|nsp.adapter.encoder|g' -i /usr/src/app/node_modules/socket.io-redis/node_modules/socket.io-adapter/index.js

CMD ["npm", "start"]
