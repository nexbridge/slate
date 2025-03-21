#!/bin/bash

THIS_DIR=`dirname $0`

cd $THIS_DIR

bundle exec middleman server

cd -
