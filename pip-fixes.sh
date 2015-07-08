#!/bin/sh 
easy_install pip
pip install --upgrade pip
pip install --upgrade wheel
rm -rf /usr/lib/python2.7/dist-packages/setuptools.egg-info 
