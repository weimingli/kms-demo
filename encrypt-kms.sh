#!/bin/bash

echo "This is a message" > text.txt

keyid="6b016347-5ecd-4bdf-8b3a-92f2b99d1758"

echo "Generating data key from AWS KMS..."
keys=($(aws kms generate-data-key --key-id $keyid --key-spec AES_256 --query [Plaintext,CiphertextBlob] --output text --profile aws-global))

#Store plaintext data key
key=$(echo -n ${keys[0]} | base64 --decode | hexdump -v -e '/1 "%02X"')

echo "Generating random initialization vector..."
aws kms generate-random --number-of-bytes 16 --profile aws-global

iv=$(aws kms generate-random --number-of-bytes 16 --query Plaintext --output text --profile aws-global | base64 --decode | hexdump -v -e '/1 "%02X"')

echo "Encrypted data key: ${keys[1]}" > encrypted.txt

#echo "Initialization vector: ${iv}" >> encrypted.txt

echo "Encrypting text file..."
echo "Encryped data: " >> encrypted.txt
openssl aes-256-cbc -iv $iv -K $key -in text.txt -a >> encrypted.txt
