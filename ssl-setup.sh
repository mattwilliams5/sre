#!/bin/bash

if [ `whoami` != 'root' ]
then
    echo "Must be root to run this script!"
    exit 1
fi

# Generate private key 
openssl genrsa -out ca.key 2048 

# Generate CSR 
openssl req -new -key ca.key -out ca.csr

# Generate Self Signed Key
openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt

# Copy the files to the correct locations
cp ca.crt /etc/pki/tls/certs
cp ca.key /etc/pki/tls/private/ca.key
cp ca.csr /etc/pki/tls/private/ca.csr

# Update all SSL certs
sed -i 's/\/etc\/pki\/tls\/certs\/localhost.crt/\/etc\/pki\/tls\/certs\/ca.crt/g' /etc/httpd/conf.d/ssl.conf
sed -i 's/\/etc\/pki\/tls\/private\/localhost.key/\/etc\/pki\/tls\/private\/ca.key/g' /etc/httpd/conf.d/ssl.conf

/etc/init.d/httpd restart
