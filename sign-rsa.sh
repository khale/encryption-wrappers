#!/bin/bash

usage() {
    echo "$0 <outfile> <infile> <privkey>"
}

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    usage
    exit 1
fi

OUTFILE="$1"
INFILE="$2"
KEYFILE="$3"

openssl dgst -sha512 -sign $KEYFILE -out $OUTFILE $INFILE
