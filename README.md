## Crypto Communication Wrappers

This is a set of scripts for manual secure communication. They're built around OpenSSL, and are basically
just wrappers around it because 
I can't seem to remember the incantations. Remember, the most secure secure thing you can do is use
a one-time pad. Just remember to watch out for those Byzantine Generals :)

## Prerequisites

### Linux
You need to have OpenSSL installed, which you probably already do. If not, go get it using your distro's package
manager. 

### Mac
Install openssl via homebrew or macports etc.

### Windows
Likewise, you'll need OpenSSL. For example, if you have choclatey, you can install via admin PowerShell:

```
$ choco install OpenSSL.light
```

## Usage
The basic idea here is that you'll derive a key either using RSA or ECDH, then use that
key to communicate using a secure block cipher (AES). You should treat this key as an ephemeral session key. Do not reuse it!

### RSA
To perform hybrid encryption with RSA, first generate a long pseudo-random key for AES. You can plug in whatever key length you'd like; 128 is the minimum
acceptable key length [recommended by NIST](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-131Ar2.pdf), but since performance is of little concern
here, why not use 256. 

```
$ ./gen-aes-key 256 > aes-key.hex
```

Encrypt this random key using `./rsa-encrypt.sh`. You first need an RSA key-pair (use a key length of at least 2048):

```
$ ./gen-rsa-key.sh 2048
```

This produces files called `private.pem` and `public.pem`. 

```
$ ./rsa-encrypt.sh aes-key.hex public.pem > ciphertext
```

This is someone else's public key (the target of the communication). Do not use RSA for encrypted communication
of long files directly (use a hybrid approach like we're doing here).

They can then decrypt as follows using their private key:

```
$ ./rsa-decrypt.sh ciphertext private.pem > aes-key.hex
```

We now have a shared secret AES key (`aes-key.hex`) which we can use for symmetric encryption. 
We can start encrypting with AES using the "with key" utility. Below we encrypt a file (`plaintext`)
using our shared key and using the "Counter" encryption mode for AES (you can also use cfb, ofb, or whatever). **Don't
use ECB or CBC**.

```
$ ./aes-encrypt-with-key.sh plaintext aes-key.hex ctr > ciphertext
```

You can now send this ciphertext along however you'd like on an untrusted medium,
e.g. 

```
$ cat ciphertext | nc termbin.com 9999
````

On the other end they can decrypt with:

``` 
$ curl -fL https://termbin.com/XXXX > cipihertext
$ ./aes-decrypt-with-key.sh ciphertext aes-key.hex ctr > plaintext
```

Or go nuts and hide it in a JPG with [steghide](http://steghide.sourceforge.net/) or or [digital ink toolkit](http://diit.sourceforge.net/index.html) or something. 

### ECDH

The tools here use the Elliptic Curve Diffie-Hellman key exchange paired with 
256-bit AES in CBC mode. The default curve over the 256-bit prime field (`secp256k1`).

Unfortunately this setup is more of a pain, because unlike with RSA, we don't generally advertise a static
public key. We will generate a shared secret for every session, then use that to encrypt. Annoying in a
manual setup, but 
more secure. The general flow is the following:

1. Receiver (`B`) generates temporary EC keypair 
2. Receiver (`B`) sends temporary public key to sender. This can be over an insecure channel.
3. Sender (`A`) generates temporary EC keypair
4. Sender (`A`) derives shared secret from `B`'s public key.
5. Sender (`A`) encrypts message with AES256, using shared secret to derive IV and symmetric key for AES.
6. Sender (`A`) generates an HMAC of encrypted message using shared ECDH secret.
7. Sender (`A`) sends HMAC, encrypted message, and temporary public key to (`B`).
8. Receiver (`B`) derives shared secret from `A`'s temporary public key.
9. Receiver (`B`) checks authenticity and integrity of encrypted message by generating his own HMAC from shared secret
   and received message, and comparing with A's HMAC.
10. Receiver (`B`) decrypts payload using shared secret to derive IV and symmetric key for AES.


We assume that A has already received `B`'s public key, here called `recv-pub.pem`. `A` can
then do the following to generate ciphertext:

```
$ ./ecdh-encrypt.sh plaintext.txt output.enc recv-pub.pem
Generating temporary ECDH keypair...
....tmppriv.pem
....tmppub.pem
Deriving shared secret...
....secret.send
Encrypting...
....output.enc
Generating HMAC...
....hmac.send
Send your public key (tmppub.pem), the encrypted data (output.enc), and the HMAC (hmac.send) to the recipient.
```

Now on the receive side, `B` can do the following to get back the plaintext:

```
$ ./ecdh-decrypt.sh recv-priv.pem output.enc foo.out tmppub.pem hmac.send
Deriving shared secret...
...secret.recv
Checking HMAC...
....HMAC OK: Match
Decrypting...
....foo.out
```

## Cryptographic Signing

TODO


## Using SSH keys
You can convert an existing ssh key into a public key using `convert-ssh.sh`. While the private key formats
are the same with SSH and OpenSSL, the public keys vary. OpenSSL uses PKCS8.
