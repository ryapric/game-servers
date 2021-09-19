FROM debian:bullseye

WORKDIR /root

COPY main.sh .
COPY games.json .
COPY docker-entrypoint.sh .

RUN bash main.sh

# No ENTRYPOINT/CMD, relegate that to each game's Dockerfile
