#!/bin/bash -uxe
#
# Prepare system for nextcloud devel
#

install_pip () {
	curl https://bootstrap.pypa.io/get-pip.py | sudo -H $PYTHON_BIN
	sudo -H pip install setuptools -U
	sudo -H pip install ansible -U
	sudo -H pip install netaddr -U
	sudo -H pip install dnspython -U
	sudo -H pip install passlib -U
	sudo -H pip install bcrypt -U
}

prepare_ubuntu() { 
	sudo apt update -y
	sudo apt dist-upgrade -y
	sudo apt install software-properties-common curl git mc vim facter python-minimal -y
	PYTHON_BIN=/usr/bin/python
	install_pip
		
	echo
	echo "Ubuntu Sytem ready for nextcloud." 
	echo
}

prepare_debian() { 
	sudo apt update -y
	sudo apt dist-upgrade -y
	sudo apt install dirmngr curl git mc vim facter python -y
	PYTHON_BIN=/usr/bin/python
	install_pip
	
	echo
	echo "Debian Sytem ready for nextcloud."
	echo
}

prepare_raspbian() {
	sudo apt update -y
	sudo apt dist-upgrade -y
	sudo apt install dirmngr mc vim git libffi-dev curl facter -y
	PYTHON_BIN=/usr/bin/python
	install_pip
	
	echo
	echo "Rasbpian System ready for nextcloud."
	echo
}

prepare_centos() { 
	sudo yum install epel-release -y
	sudo yum install git vim mc curl facter -y
	sudo yum update -y
	PYTHON_BIN=/usr/bin/python
	install_pip
	
	echo
	echo "CentOS Sytem ready for nextcloud."
	echo
}

prepare_coreos() { 
	VERSION=2.7.13.2715
	PACKAGE=ActivePython-${VERSION}-linux-x86_64-glibc-2.12-402695
	
	# make directory
	mkdir -p /opt/bin
	cd /opt
	
	wget https://downloads.activestate.com/ActivePython/releases/${VERSION}/${PACKAGE}.tar.gz
	wget https://downloads.activestate.com/ActivePython/releases/${VERSION}/SHA256SUM
	
	if [ ! $(grep ${PACKAGE}.tar.gz SHA256SUM | sha256sum --check) ] ; then
		echo "sha256sum check of ${PACKAGE}.tar.gz failed. verify download"
		exit 1
	fi
	
	tar -xzvf ${PACKAGE}.tar.gz && rm -f ${PACKAGE}.tar.gz
	
	mv ${PACKAGE} apy && cd apy && ./install.sh -I /opt/python/
	
	ln -sf /opt/python/bin/easy_install /opt/bin/easy_install
	ln -sf /opt/python/bin/pip /opt/bin/pip
	ln -sf /opt/python/bin/python /opt/bin/python
	ln -sf /opt/python/bin/python /opt/bin/python2
	ln -sf /opt/python/bin/virtualenv /opt/bin/virtualenv
	
	PYTHON_BIN=/opt/bin/python
	install_pip
	
	echo
	echo "CentOS Sytem ready for nextcloud."
	echo
}


usage() { 
	echo
	echo "Linux distribution not detected."
	echo "Use: IB=[Ubuntu|Debian|CentOS|raspbian] setup_ec2.sh"
	echo "Other distributions not yet supported."
	echo
}

if [  -f /etc/os-release ]; then 
	. /etc/os-release
elif [ -f /etc/debian_version ]; then
	$ID=debian
fi
	
case $ID in
	'ubuntu')
		prepare_ubuntu
	;;
	'debian')
		prepare_debian
	;;
        'raspbian')
                prepare_raspbian
        ;;
	'centos')
		prepare_centos
	;;
	'coreos')
		sudo prepare_coreos
	;;
	*)
		usage
	;;
esac
