#!/bin/bash

set -ex

openssl genrsa -out ca.key 2048
openssl req -new -sha256 -key ca.key -out ca.csr -subj "/CN=ROOTCA"

openssl x509 -req -days 36500 -sha256 -extensions v3_ca -signkey ca.key -in ca.csr -out ca.crt

openssl genrsa -out server.key 2048
openssl req -new -sha256 -key server.key -out server.csr -subj "/CN=llamaup.org"

openssl x509 -req -days 36500 -sha256 -extensions v3_req -CA ca.crt -CAkey ca.key -CAserial ca.srl -CAcreateserial -in server.csr -out server.crt