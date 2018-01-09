FROM sdelements/lets-chat

USER root

ENV MONGO_HOST=mongo \
    MONGO_PORT=27017

COPY docker/app/config.js /usr/src/app/app/config.js

CMD ["npm", "start"]