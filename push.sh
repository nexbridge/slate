#!/bin/bash

THIS_DIR=`dirname $0`

rm -rf $THIS_DIR/build/*

bundle exec middleman build --clean

scp -r -P 2002 $THIS_DIR/build/* root@apidocs.nexbridge.co.uk:/var/www/apidocs.nexbridge.co.uk

