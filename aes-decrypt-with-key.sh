#!/bin/bash

# $1 is input file (ciphertext)
# $2 is key
# $3 is decryption mode

usage() {
    echo "$0 <file> <key> [mode]"
    echo "mode is one of [cbc (dont use), cfb (default), ofb (faster), ctr (fastest)]"
}

if [[ -z "$1" ]]; then
    usage
    exit 1
fi

MODE=cfb

if [[ -nz "$3" ]]; then
    echo "using $3 mode"
    MODE="$3"
fi

openssl enc -aes-256-$MODE -d -in $1 -K $2
