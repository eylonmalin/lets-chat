FROM sdelements/lets-chat

USER root

ENV MONGO_HOST=mongo \
    MONGO_PORT=27017

COPY docker/app/config.js /usr/src/app/app/config.js
COPY docker/app/app.js /usr/src/app/app.js
COPY docker/app/client.js /usr/src/app/media/js/client.js

CMD ["npm", "start"]
