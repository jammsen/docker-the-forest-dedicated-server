FROM debian:stable-slim

LABEL maintainer="Sebastian Schmidt"

ENV WINEPREFIX=/wine \
    WINEARCH=win64 \
    DISPLAY=:1.0 \
    TIMEZONE=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends --no-install-suggests procps wget curl ca-certificates supervisor lib32gcc1 apt-transport-https xvfb winbind wine wine64 wine32 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . ./

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && chmod +x /usr/bin/steamcmdinstaller.sh /usr/bin/servermanager.sh /wrapper.sh

EXPOSE 8766/tcp 8766/udp 27015/tcp 27015/udp 27016/tcp 27016/udp

VOLUME ["/theforest", "/steamcmd"]

CMD ["supervisord"]
