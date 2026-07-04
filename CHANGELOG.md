# Changelog

[Back to main](README.md#changelog)

## 2026-07-04

- Updating and fixing bugs regarding Debian Trixie and Wine 11 @jammsen (#70)
- Fixed server start after base-image switch to Debian 13 (trixie): WineHQ repo now uses trixie packages
- Fixed server launch with Wine 11 (`wine64` binary was removed, now uses `wine`)
- Fixed Healthcheck and graceful shutdown: Wine 11 reports the game process as `MainThrd`, matching now via full command line (`pgrep -f`)
- Fixed password problems @jammsen (#69)
- Added FILTER_SHADER_AND_MESH_AND_WINE_DEBUG environment variable to filter out Wine debug-logs and known-harmless warning/error messages from the logs, like in the Sons-of-the-Forest image @jammsen (#71)
- The filter covers Wine debug-logs (WINEDEBUG=-all, incl. wineboot), shader warnings, headless-input NullReferenceException spam, Unity JobTempAlloc "leak" spam, deprecation messages, asset-GC housekeeping and blank lines
- Added listing of config options (ALWAYS_UPDATE_ON_START, FILTER_SHADER_AND_MESH_AND_WINE_DEBUG) to the servermanager startup output
- Renamed docker-compose.yml to compose.yml following the current Docker Compose specification @jammsen
- Updated .gitignore for the new compose file naming and local override files (compose-*.yml, custom.env) @jammsen
- Fixed inconsistent counter padding in the config-setup output (01/4 -> 01/04)
- Changed the info log color from bright blue to a theme-independent light blue (256-color) for better readability on dark terminals
- Added SteamCMD self-healing: on failure the servermanager clears SteamCMD's self-update state and retries up to 3 times, fixing the misleading "Steamcmd needs to be online to update" crash-loop caused by corrupt update state persisting in the container
- Adopted best practices from the Palworld image: base image is now digest-pinned (prevents silent base-image changes like the trixie switch), added build-time smoke tests for gosu and wine, added .dockerignore to keep game files out of the docker build context
- Installing gosu from the Debian package repository instead of shipping a binary in the repo, like in the Sons-of-the-Forest image

## 2025-07-26

- Added more readme and settings for ENV-Based settings @jammsen (#68)

## 2025-01-26

- Added Healthcheck @jammsen (#65)
- Added Changelog
- Updated Readme with a "table of contents", changelog and updated points from ideas of the Palworld Readme
- Added Feature Request template
- Updated Bug Report template
- Added CI/CD unit-test, thanks to @thijsvanloef for letting me use the base

[Back to main](README.md#changelog)