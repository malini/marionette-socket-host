#!/bin/bash

ZMQ_NAME=zeromq-4.0.4
ZMQ_DOWNLOAD_URL=http://download.zeromq.org/$ZMQ_NAME.tar.gz
echo $ZMQ_DOWNLOAD_URL
pkg-config libzmq --exists
if [ $? != 0 ]; then
  SYS=`uname -s`
  function install_zmq_from_source {
    echo "Installing zmq from source"
    /usr/bin/curl -OLsS $ZMQ_DOWNLOAD_URL
    if [ ! -d $ZMQ_NAME ]; then mkdir $ZMQ_NAME; fi
    tar --strip-components 1 -x -m -f $ZMQ_NAME.tar.gz -C $ZMQ_NAME
    pushd $ZMQ_NAME && ./configure && make && make install && popd
    if [ -d $ZMQ_NAME ]; then rm -rf $ZMQ_NAME; fi
    if [ -f $ZMQ_NAME.tar.gz ]; then rm $ZMQ_NAME.tar.gz; fi
  }
  if [ $SYS == 'Darwin' ]; then 
    echo "installing zmq from brew"
    which brew
    if [ $? == 0 ]; then
      brew install zmq
    else
      install_zmq_from_source
    fi
  else
    install_zmq_from_source
  fi
fi
