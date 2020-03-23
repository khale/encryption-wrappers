#!/bin/sh

# $1 - length (1024 is default)
#
# NOTE: if you're using this for hybrid encryption, make sure you
# use a long enough key length to accomodate whatever you're going to encrypt (e.g.
# an AES key)

LEN=1024

if [[ -n "$1" ]]; then
    echo "using length: $1"
    LEN="$1"
fi

openssl genrsa -aes128 -out private.pem $1
openssl rsa -in private.pem -pubout > public.pem
