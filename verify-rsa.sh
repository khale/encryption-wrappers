#!/bin/bash

usage() {
    echo "$0 <pub-keyfile> <sigfile> <infile>"
}

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    usage
    exit 1
fi

KEYFILE="$1"
SIGFILE="$2"
INFILE="$3"

openssl dgst -sha512 -verify $KEYFILE -signature $SIGFILE $INFILE
