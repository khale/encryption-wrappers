#!/bin/bash

usage() {
    echo "This decrypts AES256 ciphertext using ECDH key exchange."
    echo "$0 <myprivkey> <ciphertxt> <outfile> <sender-pubkey> <hmac>"
}

if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" ]]; then
    usage
    exit 1
fi

PRIVKEY="$1"
INFILE="$2"
OUTFILE="$3"
SPUB="$4"
HMAC="$5"


echo "Deriving shared secret..."
# we must have recipient's pub key here. We generate the shared secret. They must do the same
openssl pkeyutl -derive -inkey $PRIVKEY -peerkey $SPUB | base64 -w0 > secret.recv
echo "...secret.recv"

echo "Checking HMAC..."
openssl dgst -sha256 -hmac -hex -macopt hexkey:$(cat secret.recv) -out hmac.recv $INFILE

diff hmac.recv $HMAC
if [[ $? -ne 0 ]]; then 
    echo "....HMAC verification failed!"
    exit 1
else
    echo "....HMAC OK: Match"
fi

echo "Decrypting..."
# cipher: unfortunately no GCM or CTR
openssl enc -d -iter 10000 -aes-256-cbc -in $INFILE -out $OUTFILE -pass file:secret.recv
echo "....$OUTFILE"

