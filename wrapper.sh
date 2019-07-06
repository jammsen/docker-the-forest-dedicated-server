#!/usr/bin/env bash
"$@" | sed '/RenderTexture\.Create failed: format unsupported \- 2\./d'