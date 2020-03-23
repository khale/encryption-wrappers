#!/bin/bash

# $1 is input file (plaintext)
# $2 is pub key

usage() {
    echo "$0 <file> <pub-key>"
}

if [[ -z "$1" || -z "$2" ]]; then
    usage
    exit 1
fi

openssl rsautl -encrypt -inkey $2 -pubin -in $1 -oaep

