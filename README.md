# Docker - TheForest Dedicated Server

[![Build-Status master](https://github.com/jammsen/docker-the-forest-dedicated-server/blob/master/.github/workflows/docker-build-and-push.yml/badge.svg)](https://github.com/jammsen/docker-the-forest-dedicated-server/blob/master/.github/workflows/docker-build-and-push.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/jammsen/the-forest-dedicated-server)
![Docker Stars](https://img.shields.io/docker/stars/jammsen/the-forest-dedicated-server)
![Image Size](https://img.shields.io/docker/image-size/jammsen/the-forest-dedicated-server/latest)
[![Discord](https://img.shields.io/discord/532141442731212810?logo=discord&label=Discord&link=https%3A%2F%2Fdiscord.gg%2F7tacb9Q6tj)](https://discord.gg/7tacb9Q6tj)

> [!TIP]
> Do you want to chat with the community?
>
> **[Join us on Discord](https://discord.gg/7tacb9Q6tj)**

This includes a TheForest Dedicated Server based on Docker with Wine and an example config.

## Docker - Sons of the Forest Dedicated Server
If you are looking for the Sons of the Forest version, please look here: 
https://github.com/jammsen/docker-sons-of-the-forest-dedicated-server

## Do you need support for this Docker Image

- What to do?
  - Feel free to create a NEW issue
    - It is okay to "reference" that you might have the same problem as the person in issue #number
  - Follow the instructions and answer the questions of people who are willing to help you
  - If your issue is done, close it
    - I will Inactivity-Close any issue thats not been active for a week
- What NOT to do?
  - Dont re-use issues!
    - You are most likely to chat/spam/harrass thoose participants who didnt agree to be part of your / a new problem and might be totally out of context!
  - If this happens, i reserve the rights to lock the issue or delete the comments, you have been warned!

## What you need to run this
* Basic understanding of Linux and Docker

## Getting started
WARNING: If you dont do Step 1 and 2 your server can/will not save!
1. Create a new game server account over at https://steamcommunity.com/dev/managegameservers (Use AppID: `242760`)
2. Insert the Login Token into the environment variable via docker-run or docker-compose (at `SERVER_STEAM_ACCOUNT_TOKEN`)
3. Go to the directory you want to host your gameserver on your Dockernode
4. Create a sub-directory called `game`
5. Download the [docker-compose.yml](docker-compose.yml) or use the following example
6. Review the file and setup the settings you like
7. Setup Port-Forwarding or NAT for the ports in the Docker-Compose file
8. Start the container via Docker Compose
9. (Tip: Extended config settings, which are not covered by Docker Compose, can be setup in the config-file of the server - You can find it at `game/config/config.cfg`)

### Docker-Compose - Example

```yaml
version: "3.9"
services:
  the-forest-dedicated-server:
    container_name: the-forest-dedicated-server
    image: jammsen/the-forest-dedicated-server:latest
    restart: always
    environment:
      PUID: 1000
      PGID: 1000
      ALWAYS_UPDATE_ON_START: true
      SERVER_STEAM_ACCOUNT_TOKEN: YOUR_TOKEN_HERE
    ports:
      - 8766:8766/udp
      - 27015:27015/udp
      - 27016:27016/udp
    volumes:
      - ./game:/theforest
```

## Planned features in the future

- Feel free to suggest features in the issues

## Software used

- Debian Stable and SteamCMD via cm2network/steamcmd:root image as base-image
- gosu
- procps
- winbind
- wine
- xvfb
* TheForest Dedicated Server (APP-ID: 556450)
