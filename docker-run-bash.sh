#!/usr/bin/env bash
docker run --rm -i -t -p 8766:8766/udp -p 27015:27015/udp -p 27016:27016/udp -v "$(pwd)"/game:/theforest --name the-forest-dedicated-server jammsen/the-forest-dedicated-server:latest bash
