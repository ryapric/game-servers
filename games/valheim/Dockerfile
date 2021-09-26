FROM ryapric/game-servers:latest

COPY docker-entrypoint.sh .
COPY *_server.cfg ./

EXPOSE 2456-2457/tcp
EXPOSE 2456-2457/udp

ENTRYPOINT ["bash", "./docker-entrypoint.sh"]
