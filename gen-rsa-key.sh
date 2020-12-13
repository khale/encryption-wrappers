#!/bin/bash

# $1 - length (2048 is default)
#
# NOTE: if you're using this for hybrid encryption, make sure you
# use a long enough key length to accomodate whatever you're going to encrypt (e.g.
# an AES key)

LEN=2048

if [[ -n "$1" ]]; then
    echo "using length: $1"
    LEN="$1"
else
    echo "using default length: $LEN"
fi

openssl genpkey -out private.pem -algorithm rsa -pkeyopt rsa_keygen_bits:$LEN
openssl rsa -in private.pem -pubout -out public.pem
