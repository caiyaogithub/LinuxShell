#!/bin/bash
mount |grep "/dev/sr0"
if [ "$?" != 0 ];then
	mount /dev/sr0 /media
fi
[ "$?" != 0 ]&& echo "fail to mount ! exit " && exit 
yum -y install gcc-c++ ncurses-devel perl-devel 
rpm -q  gcc-c++ ncurses-devel perl-devel 
if [ "$?" != 0 ]; then
	echo "install error "
	yum -y remove gcc-c++ ncurses-devel perl-devel  
	if [ "$?" != 0 ]; then 
	echo "remove error "
	fi
fi
# install Cmake
cmake
if [ "$?" != 0 ];then
	cd /root/db/
	tar zxf /root/db/cmake-3.1.0-rc3.tar.gz  
	# get the directory after unzip 
	dname=`ls -al /root/db/ |grep "^d" |grep ".*cmake.*"|awk '{print $9}'` 
	echo "directory: "$dname
	if [ ! -d $dname ]; then
		echo "fail unzip "
		exit 
	fi
	cd /root/db/$dname
	echo "enter " `pwd`
	./bootstrap 
	if [ "$?" == 0 ];then
		gmake 
		if [ "$?" == 0 ]; then
			gmake install 
			if [ "$?" == 0 ]; then
				echo "success"
			else 
				echo "gmake install fail ! exit "
				exit 
			fi
		else 
			echo "gmake fail ! exit "
		fi
	else 
		echo " ./bootstrap fail exit "
		exit 
	fi
else 
	echo "Cmake already installed "
fi
# install mysql 
cd /root/db/
tar zxvf /root/db/mysql-5.6.20.tar.gz

mysqlD=`ls -al /root/db/ |grep "^d" |grep ".*mysql.*"|awk '{print $9}'` 

echo "mysql directory: "$mysqlD
if [ ! -d $mysqlD ]; then
	echo "mysql fail unzip "
	exit 
fi
cd /root/db/$mysqlD
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql
make && make install
# configure mysql
echo "PATH=$PATH:/usr/local/mysql/bin/" >> /etc/profile
source /etc/profile
useradd mysql
if [ "$?" != 0 ]; then
	echo "adduser error "
	exit 
fi
chown -R mysql:mysql /usr/local/mysql/
cd /usr/local/mysql/
echo "enter "`pwd`
./scripts/mysql_install_db --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data/ --user=mysql
cp support-files/mysql.server /etc/init.d/mysqld
chkconfig mysqld on
mv /etc/my.cnf /etc/my.cnf.bk
service mysqld start 
