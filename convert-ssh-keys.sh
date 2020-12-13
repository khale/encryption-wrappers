#!/bin/bash

DEFAULT_PUB=$HOME/.ssh/id_rsa.pub
DEFAULT_PRIV=$HOME/.ssh/id_rsa

# First arg is ssh priv key, then pub key

if [[ -n "$1" ]]; then
    echo "using default pubkey: $1"
    PKEY="$1"
else
    echo "using default pubkey: $DEFAULT_PUB"
    PKEY="$DEFAULT_PUB"
fi

if [[ -n "$2" ]]; then
    echo "using default privkey: $2"
    PRIVKEY="$2"
else
    echo "using default privkey: $DEFAULT_PRIV"
    PRIVKEY="$DEFAULT_PRIV"
fi

ssh-keygen -e -f $PKEY -m PKCS8 > public.pem
cp $PRIVKEY private.pem
