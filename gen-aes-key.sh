#!/bin/sh

# $1  key length

usage () {
    echo "$0 <key length (in bits)>"
}

if [[ -z "$1" ]]; then
    usage
    exit 1
fi

BYTES=$(($1/8))
openssl rand -hex $BYTES

