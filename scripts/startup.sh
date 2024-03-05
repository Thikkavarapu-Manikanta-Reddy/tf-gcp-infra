#!/bin/bash

echo "DB_USER=${DB_USERNAME}" >> .env
echo "DB_PASSWORD=${DB_PASSWORD}" >> .env
echo "DB_NAME=${DB_NAME}" >> .env
echo "DB_HOSTNAME=${DB_INTERNAL_IP_ADDRESS}" >> .env
ls -al >>debug.txt
sudo chown csye6225:csye6225 .env
sudo mv .env ${location}