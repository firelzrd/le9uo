#!/bin/sh
#
# This script is supposed to be run at .config phase before kernel compilation
# to explicitly apply sysctl defaults for:
# Lv1 protection that prevents endless system freeze on OOM
# To activate le9, user has to somehow turn off lru_gen after boot.

if [ -z "${BUILD_DIR}" ]; then BUILD_DIR="."; fi

# Enable minimal protection by default
./scripts/config --file "$BUILD_DIR/.config" --set-val CONFIG_ANON_MIN_RATIO  0
./scripts/config --file "$BUILD_DIR/.config" --set-val CONFIG_CLEAN_LOW_RATIO 0
./scripts/config --file "$BUILD_DIR/.config" --set-val CONFIG_CLEAN_MIN_RATIO 1

# Enable lru_gen at boot, to optionally activate le9 after boot by user
./scripts/config --file "$BUILD_DIR/.config" --enable LRU_GEN_ENABLED

