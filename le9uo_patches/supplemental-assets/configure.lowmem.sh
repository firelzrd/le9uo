#!/bin/sh
#
# This script is supposed to be run at .config phase before kernel compilation
# to explicitly apply sysctl defaults for:
# Lv4 protection that keeps it smooth and makes OOM killer come in haste to keep smooth after OOM
#

if [ -z "${BUILD_DIR}" ]; then BUILD_DIR="."; fi

# Enable good lowmem protection by default
./scripts/config --file "$BUILD_DIR/.config" --set-val CONFIG_ANON_MIN_RATIO  10
./scripts/config --file "$BUILD_DIR/.config" --set-val CONFIG_CLEAN_LOW_RATIO 12
./scripts/config --file "$BUILD_DIR/.config" --set-val CONFIG_CLEAN_MIN_RATIO 12

# Disable lru_gen at boot, to activate le9 at boot-time
./scripts/config --file "$BUILD_DIR/.config" --disable LRU_GEN_ENABLED

