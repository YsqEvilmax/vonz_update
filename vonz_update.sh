#!/bin/bash

docker stop vonz
docker rm vonz
docker ps -a | grep 'vonz' | awk '{print $1}' | xargs --no-run-if-empty docker rm
docker rmi -f ysqevilmax/vonz

[ -e owncloud-cert.pem -a -e owncloud-key.pem ] \
 && echo "Cert and Key Found" \
 || echo "Cert and Key not found! Re-creating now!" \
    openssl req -new -x509 -newkey rsa:2048 -days 365 -nodes\
    -keyout owncloud-key.pem \
    -out owncloud-cert.pem \
    -subj '/C=NZ/ST=ALK/L=ALK/O=UOA/OU=ECE'

docker run --rm -p 80:80 -p 443:443 --name="vonz" --hostname owncloud \
    -e OWNCLOUD_TLS_CERT=owncloud-cert.pem \
    -e OWNCLOUD_TLS_KEY=owncloud-key.pem \
    -v $(pwd)/owncloud-cert.pem:/etc/apache2/ssl/owncloud-cert.pem \
    -v $(pwd)/owncloud-key.pem:/etc/apache2/ssl/owncloud-key.pem \
    ysqevilmax/vonz

