#!/bin/bash -e

# TODO: isntall virtual env if they dont have it
# TODO: install the right version of python of they don't have it
# TODO: figure out what the right version of python is
echo "checking python version"

PYTHON_NAME=Python-2.7.5

PYTHON_DOWNLOAD_URL=https://www.python.org/ftp/python/2.7.5/Python-2.7.5.tgz

function notify_sudo {
  if [ "$SUDO_NOTIFY" = "1" ]; then
    return
  fi
  echo "Sudo access is required to install pip and/or virtualenv "
  echo "on your system.  Please enter your sudo password if prompted. "
  echo "If you don't have sudo access, you will need a system administrator "
  echo "to install python, pip and/or virtualenv for you. This is a requirement for marionette-socket-host."
  SUDO_NOTIFY=1
}

function install_python_from_source {
  /usr/bin/curl -OLsS $PYTHON_DOWNLOAD_URL
  if [ ! -d $PYTHON_NAME ]; then mkdir $PYTHON_NAME; fi
  tar --strip-components 1 -x -m -f $PYTHON_NAME.tgz -C $PYTHON_NAME
  pushd $PYTHON_NAME && ./configure && make && sudo make install && popd
  if [ -d $PYTHON_NAME ]; then rm -rf $PYTHON_NAME; fi
  if [ -f $PYTHON_NAME.tgz ]; then rm $PYTHON_NAME.tgz; fi
}

function install_python {
  notify_sudo
  SYS=`uname -s`
  if [ $SYS == 'Darwin' ]; then 
    if which brew; then
      # this is python 2.7.6 or higher
      brew install python
    else
      install_python_from_source
    fi
  elif [ $SYS == 'Linux' ]; then
    if which apt ; then
      # this is python 2.7.6 or higher
      sudo apt-get update
      sudo apt-get install python2.7
    else
      install_python_from_source
    fi
  else
    install_python_from_source
  fi
}

USE_PYTHON=`which python`
if [ -n "$PYTHON_27" ]; then
  USE_PYTHON=$PYTHON_27
fi
PYTHON_MAJOR=`$USE_PYTHON -c 'import sys; print(sys.version_info[0])'`
if [ $? != 0 ]; then
  echo "Python required, installing python 2.7.5"
  install_python
fi
PYTHON_MINOR=`$USE_PYTHON -c 'import sys; print(sys.version_info[1])'`
PYTHON_MICRO=`$USE_PYTHON -c 'import sys; print(sys.version_info[2])'`
echo $PYTHON_MAJOR
echo $PYTHON_MINOR
echo $PYTHON_MICRO
if [ $PYTHON_MAJOR -ne 2 ] || [ $PYTHON_MINOR -ne 7 ] || [ $PYTHON_MICRO -lt 5 ] ; then
  echo "Please install python 2.7.5. If you do not wish to override your system "
  echo "python, then please install python 2.7.5 and have the PYTHON_27 "
  echo "environment variable point to the location of that installation."
  exit 1
fi

echo "Setting up virtualenv"

if ! which pip; then
  if ! which easy_install; then
    echo "Neither pip nor easy_install is found in your path"
    echo "Please install pip directly using: http://pip.readthedocs.org/en/latest/installing.html#install-or-upgrade-pip"
    exit 1
  fi
  notify_sudo
  sudo easy_install pip || { echo 'error installing pip' ; exit 1; }
fi

if ! which virtualenv; then
  notify_sudo
  sudo pip install virtualenv || { echo 'error installing virtualenv' ; exit 1; }
fi

virtualenv -p $USE_PYTHON $PWD/venv
source ./venv/bin/activate
cd python/runner-service
python setup.py develop
