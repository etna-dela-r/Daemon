#!/bin/bash

# This script will be included in a deb archive as its final form
# Some translations are still missing as well.

source load_gif.sh

# Default Language if not set
LANGUAGE=${1-"en"}

# Check argument. Chain is non empty if argument digital
IS_DIGIT=`echo $1 | tr -d "[:alpha:]"`

#Check if the architecture is 64bits
uname=`uname -r|grep amd64`
if [ -n "${uname}" ]
then
    ARCH="x64"
else
    ARCH="x86"
fi

# LANGUAGE lower case
if [ -n ${LANGUAGE} ]
then
    LANGUAGE=`echo "${LANGUAGE}" | awk '{print tolower($0)}'`
fi

# Usage
if [ $# -gt 1 -o -n "${IS_DIGIT}" ] || [ "${LANGUAGE}" != "fr" -a "${LANGUAGE}" != "en" ]
then
    echo "Usage: ${0} [fr|en]";
    exit;
fi

# Must be root to install something, comment to unuse
if [ "${USER}" != "root" ]
then
    if [ "${LANGUAGE}" = "en" ]
    then
	echo "You must log in as root to proceed the installation."
	exit
    else
	echo "Veuillez vous identifier en tant que root pour proceder a l'installation."
	exit
    fi
fi

# Check if python is installed
dpkg --get-selections | grep -e '^python\s' 1>/dev/null && PYTHON=1 || PYTHON=0

# Check if make is installed
dpkg --get-selections | grep -e '^make\s' 1>/dev/null && MAKE=1 || MAKE=0

# Check if g++ is installed
dpkg --get-selections | grep -e '^g++\s' 1>/dev/null && G=1 || G=0

# Check if wget is installed
dpkg --get-selections | grep -e '^wget\s' 1>/dev/null && WGET=1 || WGET=0



# Must be root to install something, comment to unuse
if [ "${USER}" != "root" ]
then
    if [ "${LANGUAGE}" = "en" ]
    then
	echo "You must log in as root to proceed the installation."
	exit
    else
	echo "Veuillez vous identifier en tant que root pour proceder a l'installation."
	exit
    fi
fi

# Questions asked to the user
function Questions
{
if [ "${LANGUAGE}" = "fr" ]
then
    echo "L'installation de NodeJS a besoin des paquets python, make, g++ et wget pour fonctionner correctement."
    if [ ${PYTHON} -eq 1 -o ${MAKE} -eq 1 -o ${G} -eq 1 -o ${WGET} -eq 1 ]
    then
	Question_install_node 0;
    else
	Question_install_dependences ${PYTHON} ${MAKE} ${G} ${WGET};
    fi
else
    echo "NodeJS installation needs python, make and g++ packages to run."
    if [ ${PYTHON} -eq 1 -o ${MAKE} -eq 1 -o ${G} -eq 1 -o ${WGET} -eq 1 ]
    then
	Question_install_node_en 0;
    else
	Question_install_dependences_en ${PYTHON} ${MAKE} ${G} ${WGET};
    fi
fi
}

function Question_install_node
{
    if [ $1 -eq 0 ]
    then
	echo -ne "Ces quatre paquets sont deja installes.\nSouhaitez-vous proceder a l'installation de NodeJS ?[Oui|non]: ";
    else
	echo -ne "Ces quatre paquets ont ete installes.\nSouhaitez-vous proceder a l'installation de NodeJS ?[Oui|non]: ";
    fi
    read answer
    answer=`echo "${answer}" | awk '{print tolower($0)}'`
    case $answer in
        "oui") echo "NodeJS est en cours d'installation"; Install_NodeJS; echo "NodeJS est maintenant installe."; exit ;;
        "") echo "NodeJS est en cours d'installation"; Install_NodeJS; echo "NodeJS est maintenant installe."; exit ;;
        "non") echo "Vous avez quitte sans installer NodeJs."; exit ;;
	*) echo "Veuillez repondre par oui ou non."; Question_install_node $1 ;;
    esac
}

function Question_install_node_en
{
    if [ $1 -eq 0 ]
    then
	echo -ne "These four packages are already installed.\nWould you like to install NodeJS now ?[Yes|no]: ";
    else
	echo -ne "These four packages have been installed.\nWould you like to install NodeJS now ?[yes|no]: ";
    fi
    read answer
    answer=`echo "${answer}" | awk '{print tolower($0)}'`
    case $answer in
        "yes") echo "NodeJS is being installed"; Install_NodeJS; echo "NodeJS is now installed."; exit ;;
        "") echo "NodeJS is being installed"; Install_NodeJS; echo "NodeJS is now installed."; exit ;;
        "no") echo "You quitted without installing NodeJs."; exit ;;
	*) echo "Please answer yes or no."; Question_install_node_en $1 ;;
    esac
}

function Question_install_dependences
{
    echo "Les paquets suivants sont manquants :"
    [ ${PYTHON} -eq 0 ] && echo "python"
    [ ${MAKE} -eq 0 ] && echo "make"
    [ ${G} -eq 0 ] && echo "g++"
    [ ${WGET} -eq 0 ] && echo "wget"
    echo -n "Souhaitez-vous que ce script les installe ?[Oui|non]: "
    read answer
    case $answer in
        "oui") echo "Dependences en cours d'installation."; Install_dependences ${PYTHON} ${MAKE} ${G} ${WGET}; echo "Installation des dependences terminee." ;;
        "") echo "Dependences en cours d'installation."; Install_dependences ${PYTHON} ${MAKE} ${G} ${WGET}; echo "Installation des dependences terminee." ;;
        "non") echo -e "NodeJS ne peut pas fonctionner sans ces dependences.\nVeillez a les installer avant d'installer NodeJS."; exit ;;
	*) echo "Veuillez repondre par oui ou non."; Question_install_dependences ${PYTHON} ${MAKE} ${G} ${WGET} ;;
    esac
}

function Question_install_dependences_en
{
    echo "Following packages are missing :"
    [ ${PYTHON} -eq 0 ] && echo "python"
    [ ${MAKE} -eq 0 ] && echo "make"
    [ ${G} -eq 0 ] && echo "g++"
    [ ${WGET} -eq 0 ] && echo "wget"
    echo -n "Do you want this script to install them ?[Yes/no]: "
    read answer
    case $answer in
        "yes") echo "Dependences are being installed."; Install_dependences ${PYTHON} ${MAKE} ${G} ${WGET}; echo "Missing dependences are now installed." ;;
        "") echo "Dependences are being installed."; Install_dependences ${PYTHON} ${MAKE} ${G} ${WGET}; echo "Missing dependences are now installed." ;;
        "no") echo -e "NodeJS can't work without these dependences.\nMake sure these are installed before you install NodeJS."; exit ;;
	*) echo "Please answer yes or no."; Question_install_dependences_en ${PYTHON} ${MAKE} ${G} ${WGET} ;;
    esac
}




# Installation functions
function Install_dependences
{
    [ ${PYTHON} -eq 0 ] && echo "python" && aptitude install python 1>/dev/null;
#    echo -e "\n#-#-#-#-#-#\npython is being installed\n#-#-#-#-#-#" && Load_gif
    [ ${MAKE} -eq 0 ] && echo "make" && aptitude install make 1>/dev/null;
#    echo -e "\n#-#-#-#-#-#\nmake is being installed\n#-#-#-#-#-#" && Load_gif
    [ ${G} -eq 0 ] && echo "g++" && aptitude install g++;
#    echo -e "\n#-#-#-#-#-#\ng++ is being installed\n#-#-#-#-#-#" && Load_gif
    [ ${WGET} -eq 0 ] && echo "wget" && aptitude install wget;
#    echo -e "\n#-#-#-#-#-#\nwget is being installed\n#-#-#-#-#-#" && Load_gif
    Question_install_node 1;
}

function Install_NodeJS
{
    mkdir /tmp/nodejs && cd $_

    echo -e "\n#-#-#-#-#\nRecuperation du fichier d'installation de NodeJS\n#-#-#-#-#\n"
    wget -N http://nodejs.org/dist/v0.10.9/node-v0.10.9-linux-${ARCH}.tar.gz 1>/dev/null 2>/dev/null &
    Load_gif

    #Check the downloaded archive
    sha1sum node-v0.10.9-linux-${ARCH}.tar.gz > /tmp/shasum
    checksum=`sha1sum -c /tmp/shasum`
    if [ $? -ne 0 ]
    then
	Error "sha1sum" $? $checksum
    fi
    
    echo -e "\n#-#-#-#-#\nDesarchivage du paquet\n#-#-#-#-#\n"
    tar xzvf node-v0.10.9-linux-${ARCH}.tar.gz 1>/dev/null &
    Load_gif
    cd node-v0.10.9-linux-${ARCH}

    echo -e "\n#-#-#-#-#\nInstallation de NodeJS\n#-#-#-#-#\n"
    ./configure &
	Load_gif
    make &
	Load_gif
    make install &
	Load_gif

    echo -e "\n#-#-#-#-#\nSuppression des dossiers temporaires\n#-#-#-#-#\n"
    cd && rm -rf /tmp/nodejs >> /dev/nul &
    Load_gif
	
	npm config set registry http://registry.npmjs.org/
}

# Gestion d'erreurs
function Error
{
    prog=$1
    code=$2
    msg=$3

    echo -e "\nL'erreur est survenue lors de l'execution de ${prog:\n${code}: ${msg}\n"
    exit;
}




# While script is running, it asks the user
Questions "$LANGUAGE" ${PYTHON} ${MAKE} ${G} ${WGET}
