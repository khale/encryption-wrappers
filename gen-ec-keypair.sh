#!/bin/bash
echo "Generating EC keypair with secp256k1."
echo "...ecprivate.pem"
echo "...ecpublic.pem"
openssl ecparam -genkey -name secp256k1 -out ec_parm_and_key.pem
openssl pkey -in ec_parm_and_key.pem -out ecprivate.pem
openssl pkey -in ec_parm_and_key.pem -pubout -out ecpublic.pem
