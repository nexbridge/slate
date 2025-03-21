#!/bin/bash

THIS_DIR=`dirname $0`

cd $THIS_DIR

rm -rf $THIS_DIR/build/*

bundle exec middleman build --clean

scp -r $THIS_DIR/build/* root@web1.do.nexbridge.co.uk:/var/www/apidocs.nexbridge.co.uk

cd -
