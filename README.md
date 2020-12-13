## Crypto Communication Wrappers

This is a set of scripts for manual secure communication. They're built around OpenSSL, and are basically
just wrappers around it because 
I can't seem to remember the incantations. Remember, the most secure 

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
The basic idea here is that you'll derive a key either using RSA or a diffie-hellman exchange, then use that
key to communicate using a secure cipher (AES). You should treat this key as an ephemeral session key. Do not reuse it. 

### RSA
To do custom hybrid encryption with RSA, first generate a long pseudo-random key for AES. You can plug in whatever key length you'd like; 128 is the minimum
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
