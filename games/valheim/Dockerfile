FROM ryapric/game-servers:latest

COPY main.sh .
COPY *_server.cfg .

EXPOSE 2456-2457/tcp
EXPOSE 2456-2457/udp

ENTRYPOINT ["bash", "./main.sh"]
