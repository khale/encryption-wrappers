#!/bin/sh
# $1 pub key file

usage () {
    echo "$0 <pub-key>"
}

if [[ -z "$1" ]]; then
    usage
    exit 1
fi

openssl rsa -in $1 -pubin -text -noout
