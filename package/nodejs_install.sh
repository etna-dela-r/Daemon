#!/bin/sh

# This script will be included in a deb archive as its final form
# Some translations are still missing as well.

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

# Check if checkinstall is installed
dpkg --get-selections | grep -e '^checkinstall\s' | grep -v deinstall 1>/dev/null && CHECKINSTALL=1 || CHECKINSTALL=0

# Check if gcc is installed
dpkg --get-selections | grep -e '^gcc\s' | grep -v deinstall 1>/dev/null && GCC=1 || GCC=0

# Check if python is installed
dpkg --get-selections | grep -e '^python\s' | grep -v deinstall  1>/dev/null && PYTHON=1 || PYTHON=0

# Check if make is installed
dpkg --get-selections | grep -e '^make\s' | grep -v deinstall 1>/dev/null && MAKE=1 || MAKE=0

# Check if g++ is installed
dpkg --get-selections | grep -e '^g++\s' | grep -v deinstall 1>/dev/null && G=1 || G=0

# Check if wget is installed
dpkg --get-selections | grep -e '^wget\s' | grep -v deinstall 1>/dev/null && WGET=1 || WGET=0

# Check if transmission is installed
dpkg --get-selections | grep -e '^transmission-daemon\s' | grep -v deinstall 1>/dev/null && TRANSMISSION=1 || TRANSMISSION=0

# Assume that dependencies are not installed at first
DEPENDENCES=0;



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
Questions ()
{
if [ "${LANGUAGE}" = "fr" ]
then
    echo "L'installation de NodeJS a besoin des paquets python, make, g++ et wget pour fonctionner correctement."
    if [ ${CHECKINSTALL} -eq 1 -a ${PYTHON} -eq 1 -a ${MAKE} -eq 1 -a ${G} -eq 1 -a ${GCC} -eq 1 -a ${WGET} -eq 1 ]
    then
	if [ ${TRANSMISSION} -eq 0 ]
	then
	    Question_install_transmission;
	fi
	Question_install_node;
    else
	Question_install_dependences ${CHECKINSTALL} ${PYTHON} ${MAKE} ${G} ${GCC} ${WGET};
    fi
else
    echo "NodeJS installation needs python, make and g++ packages to run."
    if [ ${CHECKINSTALL} -eq 1 -a ${PYTHON} -eq 1 -a ${MAKE} -eq 1 -a ${G} -eq 1 -a ${GCC} -eq 1 -a ${WGET} -eq 1 ]
    then
	if [ ${TRANSMISSION} -eq 0 ]
	then
	    Question_install_transmission;
	fi
	Question_install_node_en;
    else
	Question_install_dependences_en ${CHECKINSTALL} ${PYTHON} ${MAKE} ${G} ${GCC} ${WGET} ${TRANSMISSION};
    fi
fi
}

Question_install_node ()
{
    echo -n "Souhaitez-vous proceder a l'installation de NodeJS ?[Oui|non]: ";
    read answer
    answer=`echo "${answer}" | awk '{print tolower($0)}'`
    case $answer in
        "oui") echo "NodeJS est en cours d'installation"; Install_NodeJS; echo "NodeJS est maintenant installe."; exit ;;
        "") echo "NodeJS est en cours d'installation"; Install_NodeJS; echo "NodeJS est maintenant installe."; exit ;;
        "non") echo "Vous avez quitte sans installer NodeJs."; exit ;;
	*) echo "Veuillez repondre par oui ou non."; Question_install_node ;;
    esac
}

Question_install_node_en ()
{
    echo -n "Would you like to install NodeJS now ?[yes|no]: ";
    read answer
    answer=`echo "${answer}" | awk '{print tolower($0)}'`
    case $answer in
        "yes") echo "NodeJS is being installed"; Install_NodeJS; echo "NodeJS is now installed."; exit ;;
        "") echo "NodeJS is being installed"; Install_NodeJS; echo "NodeJS is now installed."; exit ;;
        "no") echo "You quitted without installing NodeJs."; exit ;;
	*) echo "Please answer yes or no."; Question_install_node_en ;;
    esac
}

Question_install_dependences ()
{
    echo "Les paquets suivants sont manquants :"
    [ ${CHECKINSTALL} -eq 0 ] && echo "checkinstall"
    [ ${GCC} -eq 0 ] && echo "gcc"
    [ ${PYTHON} -eq 0 ] && echo "python"
    [ ${MAKE} -eq 0 ] && echo "make"
    [ ${G} -eq 0 ] && echo "g++"
    [ ${WGET} -eq 0 ] && echo "wget"
    echo -n "Souhaitez-vous que ce script les installe ?[Oui|non]: "
    read answer
    case $answer in
        "oui") echo "Dependences en cours d'installation."; Install_dependences ${CHECKINSTALL} ${PYTHON} ${MAKE} ${G} ${GCC} ${WGET}; echo "Installation des dependences terminee." ;;
        "") echo "Dependences en cours d'installation."; Install_dependences ${CHECKINSTALL} ${PYTHON} ${MAKE} ${G} ${GCC} ${WGET}; echo "Installation des dependences terminee." ;;
        "non") echo -e "NodeJS ne peut pas fonctionner sans ces dependences.\nVeillez a les installer avant d'installer NodeJS."; exit ;;
	*) echo "Veuillez repondre par oui ou non."; Question_install_dependences ${CHECKINSTALL} ${PYTHON} ${MAKE} ${G} ${GCC} ${WGET} ;;
    esac
}

Question_install_dependences_en ()
{
    echo "Following packages are missing :"
    [ ${CHECKINSTALL} -eq 0 ] && echo "checkinstall"
    [ ${GCC} -eq 0 ] && echo "gcc"
    [ ${PYTHON} -eq 0 ] && echo "python"
    [ ${MAKE} -eq 0 ] && echo "make"
    [ ${G} -eq 0 ] && echo "g++"
    [ ${WGET} -eq 0 ] && echo "wget"
    echo -n "Do you want this script to install them ?[Yes/no]: "
    read answer
    case $answer in
        "yes") echo "Dependences are being installed."; Install_dependences ${CHECKINSTALL} ${PYTHON} ${MAKE} ${G} ${GCC} ${WGET}; echo "Missing dependences are now installed." ;;
        "") echo "Dependences are being installed."; Install_dependences ${CHECKINSTALL} ${PYTHON} ${MAKE} ${G} ${GCC} ${WGET} ${TRANSMISSION}; echo "Missing dependences are now installed." ;;
        "no") echo -e "NodeJS can't work without these dependences.\nMake sure these are installed before you install NodeJS."; exit ;;
	*) echo "Please answer yes or no."; Question_install_dependences_en ${CHECKINSTALL} ${PYTHON} ${MAKE} ${G} ${GCC} ${WGET} ;;
    esac
}

Question_install_transmission ()
{
    if [ ${DEPENDENCES} -eq 0 ]
    then
	printf "These four packages are already installed.\n\n";
    else
	printf "These four packages have been installed.\n\n";
    fi
    echo -n "Would you like to install transmission-daemon (BitTorrent client)? [Yes/no]: "
    read answer
    case $answer in
	"yes") echo "transmission-daemon is being installed."; Install_transmission; echo "transmission-daemon is now installed" ;;
	"no") printf "You choosed not to install transmission-daemon. You can still install it by yourself whith the command:\n\taptitude install transmission-daemon\n\n" ;;
	"") echo "transmission-daemon is being installed."; Install_transmission; echo "transmission-daemon is now installed.\n\n" ;;
	*) echo "Please answer yes or no."; Question_install_transmission ;;
    esac

    Question_install_node_en
}






# Installation functions
Install_dependences ()
{

    [ ${CHECKINSTALL} -eq 0 ] && echo "checkinstall" && aptitude install checkinstall;
#    echo -e "\n#-#-#-#-#-#\ncheckinstall is being installed\n#-#-#-#-#-#" && Load_gif
    [ ${GCC} -eq 0 ] && echo "gcc" && aptitude install gcc 1>/dev/null;
#    echo -e "\n#-#-#-#-#-#\ngcc is being installed\n#-#-#-#-#-#" && Load_gif
    [ ${PYTHON} -eq 0 ] && echo "python" && aptitude install python 1>/dev/null;
#    echo -e "\n#-#-#-#-#-#\npython is being installed\n#-#-#-#-#-#" && Load_gif
    [ ${MAKE} -eq 0 ] && echo "make" && aptitude install make 1>/dev/null;
#    echo -e "\n#-#-#-#-#-#\nmake is being installed\n#-#-#-#-#-#" && Load_gif
    [ ${G} -eq 0 ] && echo "g++" && aptitude install g++;
#    echo -e "\n#-#-#-#-#-#\ng++ is being installed\n#-#-#-#-#-#" && Load_gif
    [ ${WGET} -eq 0 ] && echo "wget" && aptitude install wget;
#    echo -e "\n#-#-#-#-#-#\nwget is being installed\n#-#-#-#-#-#" && Load_gif
#    [ ${TRANSMISSION} -eq 0 ] && echo "transmission" && aptitude install transmission;
#    echo -e "\n#-#-#-#-#-#\ntransmission is being installed\n#-#-#-#-#-#" && Load_gif
    DEPENDENCES=1

    if [ ${TRANSMISSION} -eq 0 ]
    then
	Question_install_transmission;
    else
	Question_install_node_en;
    fi
}

Install_transmission ()
{
    aptitude -y install transmission-daemon;
}

Install_NodeJS ()
{
    TMPDIR=/tmp/nodejs_shunt

    mkdir $TMPDIR
    cd $TMPDIR

    printf "\n#-#-#-#-#\nRecuperation du fichier d'installation de NodeJS\n#-#-#-#-#\n"
    wget -N http://eip.pnode.fr/node-latest.tar.gz

    #Check the downloaded archive
#    sha1sum node-v0.10.18-linux-${ARCH}.tar.gz > /tmp/shasum
    sha1sum node-latest.tar.gz > /tmp/shasum
    checksum=`sha1sum -c /tmp/shasum`
    if [ $? -ne 0 ]
    then
	Error "sha1sum" $? $checksum
    fi
    
    printf "\n#-#-#-#-#\nDesarchivage du paquet\n#-#-#-#-#\n"
#    tar xzvf node-v0.10.18-linux-${ARCH}.tar.gz 1>/dev/null &
    tar xzvf node-latest.tar.gz 1>/dev/null &
    Load_gif
#    cd /tmp/nodejs_shunt/node-v0.10.18-linux-${ARCH}
    cd $TMPDIR/node-v*
 
    printf "\n#-#-#-#-#\nInstallation de NodeJS\n#-#-#-#-#\n"
    ./configure
    make
    make install

    printf "\n#-#-#-#-#\nSuppression des dossiers temporaires\n#-#-#-#-#\n"
    cd
    rm -rf $TMPDIR >> /dev/nul &
    Load_gif

    npm config set registry http://registry.npmjs.org;
}





# Gestion d'erreurs
Error ()
{
    prog=$1
    code=$2
    msg=$3

    printf "\nL'erreur est survenue lors de l'execution de ${prog}:\n${code}: ${msg}\n"
    exit;
}




# Outils
Load_gif ()
{
    pid=$!

    while [ -d /proc/${pid} ];
    do
        printf "\r|"
        sleep 0.2
        printf "\r/"
        sleep 0.2
        printf "\r-"
        sleep 0.2
        printf "\r\\"
        sleep 0.2
    done
    printf "\r";
}



# While script is running, it asks the user
Questions "$LANGUAGE" ${CHECKINSTALL} ${PYTHON} ${MAKE} ${G} ${GCC} ${WGET}
