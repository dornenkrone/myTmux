#!/usr/bin/env bash

# Personal build script for my WSL

set -e

sudo aptitude install libx11-dev libxtst-dev libxi-dev libxext-dev
rm -r ./target
cargo build --release
mkdir -p ~/.tmux/bin
mv target/release/apm_counter /bin/apm_counter
# cp target/x86_64-pc-windows-gnu/release/apm_display.exe /mnt/c/Users/samuf/Desktop/APM.exe
