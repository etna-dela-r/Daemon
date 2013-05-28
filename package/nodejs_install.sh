#!/bin/bash

# This script will be included in a deb archive as its final form
# Some translations are still missing as well.

source load_gif.sh

# Default Language if not set
LANGUAGE=${1-"en"}

# Check argument. Chain is non empty if argument digital
IS_DIGIT=`echo $1 | tr -d "[:alpha:]"`

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
dpkg --get-selections | grep -e '^python\s' >> /dev/null && PYTHON=1 || PYTHON=0

# Check if make is installed
dpkg --get-selections | grep -e '^make\s' >> /dev/null && MAKE=1 || MAKE=0

# Check if g++ is installed
dpkg --get-selections | grep -e '^g++\s' >> /dev/null && G=1 || G=0

# Check if wget is installed
dpkg --get-selections | grep -e '^wget\s' >> /dev/null && WGET=1 || WGET=0


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
	echo -ne "Ces quatre paquets sont deja installes.\nSouhaitez-vous proceder a l'installation de NodeJS ?[Oui|Non]: ";
    else
	echo -ne "Ces quatre paquets ont ete installes.\nSouhaitez-vous proceder a l'installation de NodeJS ?[Oui|Non]: ";
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
	echo -ne "These four packages are already installed.\nWould you like to install NodeJS now ?: ";
    else
	echo -ne "These four packages have been installed.\nWould you like to install NodeJS now ?: ";
    fi
    read answer
    answer=`echo "${answer}" | awk '{print tolower($0)}'`
    case $answer in
        "yes") echo "NodeJS is being installed"; Install_NodeJS; echo "NodeJS is now installed."; exit ;;
        "no") echo "You quit without installing NodeJs."; exit ;;
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
    echo -n "Souhaitez-vous que ce script les installe ?[Oui|Non]: "
    read answer
    case $answer in
        "oui") echo "Dependences en cours d'installation."; Install_dependences ${PYTHON} ${MAKE} ${G} ${WGET}; echo "Installation des dependences terminee." ;;
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
    echo -n "Do you want this script to install them ?: "
    read answer
    case $answer in
        "yes") echo "Dependences are being installed."; Install_dependences ${PYTHON} ${MAKE} ${G} ${WGET}; echo "Missing dependences are now installed." ;;
        "no") echo -e "NodeJS can't work without these dependences.\nMake sure these are installed before you install NodeJS."; exit ;;
	*) echo "Please answer yes or no."; Question_install_dependences_en ${PYTHON} ${MAKE} ${G} ${WGET} ;;
    esac
}




# Installation functions
function Install_dependences
{
#    [ ${PYTHON} -eq 0 ] && echo "python" && aptitude install python >> /dev/null;
#    [ ${MAKE} -eq 0 ] && echo "make" && aptitude install make >> /dev/null;
#    [ ${G} -eq 0 ] && echo "g++" && aptitude install g++;
#    [ ${WGET} -eq 0 ] && echo "wget" && aptitude install wget;
    Question_install_node 1;
}

function Install_NodeJS
{
    mkdir /tmp/nodejs && cd $_
    echo -e "\n#-#-#-#-#\nRecuperation du fichier d'installation de NodeJS\n#-#-#-#-#\n"
    wget -N http://nodejs.org/dist/node-latest.tar.gz >> /dev/null
    echo -e "\n#-#-#-#-#\nDesarchivage du paquet\n#-#-#-#-#\n"
    tar xzvf node-latest.tar.gz >> /dev/null && cd `ls -rd node-v*` &
    Load_gif
#    ./configure
#    make install
    echo -e "\n#-#-#-#-#\nSuppression des dossiers temporaires\n#-#-#-#-#\n"
    cd && rm -rf /tmp/nodejs >> /dev/nul &
    Load_gif
}



# While script is running, it asks the user
Questions "$LANGUAGE" ${PYTHON} ${MAKE} ${G} ${WGET}
