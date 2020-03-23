#!/bin/sh

# $1 - file to hash
# $2 - secret key


usage () {
    echo "$0 <input file> <secret-key>"
}

if [[ -z "$1" ]] ; then
    usage
    exit 1
fi

if [[ -z "$2" ]] ; then
    usage
    exit 1
fi

cat $1 | openssl dgst -sha512 -hmac $2
