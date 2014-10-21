#!/bin/bash -e

# TODO: isntall virtual env if they dont have it
# TODO: install the right version of python of they don't have it
# TODO: figure out what the right version of python is
echo "checking python version"

USE_PYTHON=`which python`
if [ -n "$PYTHON_27" ]; then
  USE_PYTHON=$PYTHON_27
fi
PYTHON_MAJOR=`$USE_PYTHON -c 'import sys; print(sys.version_info[0])'`
if [ $? != 0 ]; then
  echo "Python required, please install python 2.7.5"
  exit 1
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
function notify_sudo {
  if [ "$SUDO_NOTIFY" = "1" ]; then
    return
  fi
  echo "Sudo access is required to install pip and/or virtualenv "
  echo "on your system.  Please enter your sudo password if prompted. "
  echo "If you don't have sudo access, you will need a system administrator "
  echo "to install pip and virtualenv for you. This is a requirement for marionette-socket-host."
  SUDO_NOTIFY=1
}

which pip
if [ $? != 0 ]; then
  which easy_install
  if [ $? != 0 ]; then
    echo "Neither pip nor easy_install is found in your path"
    echo "Please install pip directly using: http://pip.readthedocs.org/en/latest/installing.html#install-or-upgrade-pip"
    exit 1
  fi
  notify_sudo
  sudo easy_install pip || { echo 'error installing pip' ; exit 1; }
fi

which virtualenv
if [ $? != 0 ]; then
  notify_sudo
  sudo pip install virtualenv || { echo 'error installing virtualenv' ; exit 1; }
fi

virtualenv -p $USE_PYTHON $PWD/venv
source ./venv/bin/activate
cd python/runner-service
python setup.py develop
