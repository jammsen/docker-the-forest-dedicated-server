FROM jammsen/base:wine-stable-debian-bullseye

LABEL maintainer="Sebastian Schmidt"

ENV WINEPREFIX=/winedata/WINE64 \
    WINEARCH=win64 \
    DISPLAY=:1.0 \
    TIMEZONE=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0 \
    SERVER_STEAM_ACCOUNT_TOKEN=""

VOLUME ["/theforest", "/steamcmd"]

EXPOSE 8766/tcp 8766/udp 27015/tcp 27015/udp 27016/tcp 27016/udp

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get dist-upgrade -y \
#    && apt-get install -y --no-install-recommends --no-install-suggests lib32gcc-s1 nano supervisor winbind xvfb \
    && apt-get install -y --no-install-recommends --no-install-suggests lib32gcc-s1 nano winbind xvfb \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . ./

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && chmod +x /usr/bin/steamcmdinstaller.sh /usr/bin/servermanager.sh

CMD ["servermanager.sh"]