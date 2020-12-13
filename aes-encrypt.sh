#!/bin/bash

# $1 is input file (plaintext)
# $2 is encryption mode

usage() {
    echo "$0 <file> [mode]"
    echo "mode is one of [cbc (dont use), cfb (default), ofb (faster), ctr (fastest)]"
}

if [[ -z "$1" ]]; then
    usage
    exit 1
fi

MODE=cfb

if [[ -n "$2" ]]; then
    echo "using $2 mode"
    MODE="$2"
fi

openssl enc -aes-256-$MODE -e -in $1 
