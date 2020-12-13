#!/bin/bash

usage() {
    echo "This generates a shared secret using the Elliptic Curve Diffie Hellman key exchange" \
          "and produces ciphertext using the AES 256-bit block cipher with CBC mode." \
          "Default is to use NIST/SECG curve over 256 bit prime field. Also includes secure digest."
    echo "$0 <plaintxt> <outfile> <reciever-pubkey>"
}

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    usage
    exit 1
fi

INFILE="$1"
OUTFILE="$2"
RPUB="$3"

echo "Generating temporary ECDH keypair..."
openssl ecparam -genkey -name secp256k1 -out ec-tmp-pair.pem
openssl pkey -in ec-tmp-pair.pem -out tmppriv.pem

echo "....tmppriv.pem"

# we will send this pubkey along with the encrypted msg
openssl pkey -in ec-tmp-pair.pem -pubout -out tmppub.pem
echo "....tmppub.pem"

echo "Deriving shared secret..."
# we must have recipient's pub key here. We generate the shared secret. They must do the same
openssl pkeyutl -derive -inkey tmppriv.pem -peerkey $RPUB | base64 -w0 > secret.send
echo "....secret.send"

echo "Encrypting..."
# cipher: unfortunately no GCM or CTR
openssl enc -iter 10000 -aes-256-cbc -in $INFILE -out $OUTFILE -pass file:secret.send
echo "....$OUTFILE"

echo "Generating HMAC..."
# HMAC gives us both authenticity and integrity
openssl dgst -sha256 -hmac -hex -macopt hexkey:$(cat secret.send) -out hmac.send $OUTFILE
echo "....hmac.send"
echo "Send your public key (tmppub.pem), the encrypted data ($OUTFILE), and the HMAC (hmac.send) to the recipient."
