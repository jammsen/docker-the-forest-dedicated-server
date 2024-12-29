#!/usr/bin/env bash

docker run --rm -i -t -e 'SERVER_STEAM_ACCOUNT_TOKEN=YOUR_TOKEN_HERE' -p 8766:8766/tcp -p 8766:8766/udp -p 27015:27015/tcp -p 27015:27015/udp -p 27016:27016/tcp -p 27016:27016/udp --name the-forest-dedicated-server jammsen/the-forest-dedicated-server:latest
#docker run --rm -i -t -e 'SERVER_STEAM_ACCOUNT_TOKEN=YOUR_TOKEN_HERE' -p 8766:8766/tcp -p 8766:8766/udp -p 27015:27015/tcp -p 27015:27015/udp -p 27016:27016/tcp -p 27016:27016/udp -v $(pwd)/theforest/steamcmd:/steamcmd -v $(pwd)/theforest/game:/theforest --name the-forest-dedicated-server jammsen/the-forest-dedicated-server:latest
