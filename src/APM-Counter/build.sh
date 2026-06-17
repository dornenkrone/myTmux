#!/usr/bin/env bash

# Personal build script for my WSL

set -e

sudo aptitude install libx11-dev libxtst-dev libxi-dev libxext-dev

cargo build --release
# cp target/x86_64-pc-windows-gnu/release/apm_display.exe /mnt/c/Users/samuf/Desktop/APM.exe
