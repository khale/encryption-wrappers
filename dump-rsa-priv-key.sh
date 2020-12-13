#!/bin/bash
# $1 priv key file

usage () {
    echo "$0 <private-key>"
}

if [[ -z "$1" ]]; then
    usage
    exit 1
fi

openssl rsa -in $1 -text -noout
