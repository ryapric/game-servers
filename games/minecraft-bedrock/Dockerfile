FROM ryapric/game-servers:latest

ARG minecraft_version=1.17.31.01

WORKDIR /root/minecraft

RUN apt-get install -y \
      nano \
      unzip && \
    curl \
      -fsSL \
      -o minecraft.zip \
      "https://minecraft.azureedge.net/bin-linux/bedrock-server-${minecraft_version}.zip" && \
    unzip -q minecraft.zip && \
    rm minecraft.zip && \
    mv ./bedrock_server /usr/local/bin/ && \
    mkdir -p ./WORLDS

EXPOSE 19132/udp

COPY docker-entrypoint.sh .
ENTRYPOINT ["bash", "docker-entrypoint.sh"]
