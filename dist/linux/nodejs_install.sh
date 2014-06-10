#!/bin/sh

# This script is here to automate the installation of NodeJS
# Base on https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager, "Debian - Build from source" section

USER=$(whoami)

if [ "${USER}" != "root" ]
then
    echo "You need root privileges to run the script and install nodeJS."
    exit 1
fi

echo "
### BEGINING NODEJS INSTALLATION ###
This might take a while. Please hit RETURN to proceed, or ^C to abort.
"
read answer
cd /tmp
src=$(mktemp -d)
cd $src

echo "
### GETTING NODEJS ARCHIVE ###
"
wget -N http://nodejs.org/dist/v0.10.29/node-v0.10.29.tar.gz
tar xzvf node-v0.10.29.tar.gz
cd node-v0.10.29

echo "
### CONFIGURING FILES ###
"
./configure
fakeroot checkinstall -y --install=no --pkgversion $(echo $(pwd) | sed -n -re's/.+node-v(.+)$/\1/p') make -j$(($(nproc)+1)) install

echo "
### INSTALLING NODEJS ###
"
dpkg -i node_0.10.29*

echo "
### DELETING TEMPORARY FILES ###
"
cd /tmp
rm -rf $src

echo "
Nodejs has been installed on your computer. You can now proceed with Shunt installation by running:
   dpkg -i shunt.deb

To uninstall NodeJS, simply run:
   dpkg -r node
"
