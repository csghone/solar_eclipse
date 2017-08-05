#!/bin/bash -xe

# Removes comments to allow quick editing in camera
cat eclipse_magic.lua  | grep '^\s+$' -v  |grep -v '^\ *--.*'  |sed '/^$/N;/^\n$/D' > eclipse_magic_clean.lua


