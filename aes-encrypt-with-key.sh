#!/bin/bash

# $1 is input file (plaintext)
# $2 is 256-bit encryption key
# $3 is encryption mode

usage() {
    echo "$0 <file> <key> [mode]"
    echo "mode is one of [cbc (dont use), cfb (default), ofb (faster), ctr (fastest)]"
}

if [[ -z "$1"  || -z "$2" ]]; then
    usage
    exit 1
fi

MODE=cfb

if [[ -nz "$3" ]]; then
    echo "using $3 mode"
    MODE="$3"
fi

openssl enc -aes-256-$MODE -e -in $1 -K $2
