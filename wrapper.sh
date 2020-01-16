#!/usr/bin/env bash
# Removing possible old X-Window-Lock
rm /tmp/.X1-lock
"$@" | sed '/RenderTexture\.Create failed: format unsupported \- 2\./d'