#!/bin/bash

# $1 is input file (ciphertext)
# $2 is priv key

usage() {
    echo "$0 <file> <priv-key>"
}

if [[ -z "$1" || -z "$2" ]]; then
    usage
    exit 1
fi

openssl rsautl -decrypt -inkey $2 -in $1 -oaep

