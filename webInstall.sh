#!/bin/bash

mount |grep "/dev/sr0"
if [ "$?" != 0 ]; then
	mount /dev/sr0 /media 
fi
[ "$?" != 0 ] && echo "fail to mount ! exit " && exit 
# install gcc-c++
rpm -q gcc-c++
if [ "$?" != 0 ]; then
	yum -y install gcc-c++
fi
# remove httpd
rpm -q httpd 
if [ "$?" == 0 ]; then
	rpm -e httpd --nodeps
fi
yum -y install perl-devel freetype-devel libxml2-devel libXpm-devel zlib-devel libpng-devel
[ "$?" != 0 ] && echo "perl-devel freetype-devel libxml2-devel libXpm-devel zlib-devel libpng-devel yum error ! exit " && exit 
# install APR(Apache Portable Runtime)
tar -jxvf /root/web/apr-1.5.1.tar.bz2

APR=`ls -al /root/web/ |grep "^d" |grep ".*apr.*"|awk '{print $9}'` 
[ "$APR" == "" ] && echo " apr unzip error ! exit " && exit 
cd /root/web/$APR
echo "enter " `pwd`
./configure --prefix=/usr/local/apr
if [ "$?" ==  0 ];then
	make && make install 
	if [ "$?" == 0 ]; then 
		echo "apr install success"
	else 
		echo "apr make && make install error ! exit "
		exit 
	fi
else 
	echo "apr ./configure error ! exit "
	exit 
fi
# install apr-util
tar -jvxf /root/web/apr-util-1.5.3.tar.bz2

APRU=`ls -al /root/web/ |grep "^d" |grep ".*apr-util*"|awk '{print $9}'` 
[ "$APRU" == "" ] && echo " apr-util unzip error ! exit " && exit 
echo "apr-util "$APRU
cd /root/web/$APRU
echo "enter "$APRU
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/
if [ "$?" ==  0 ];then
	make && make install 
	if [ "$?" == 0 ]; then 
		echo "apr-util install success"
	else 
		echo "apr-util make && make install error ! exit "
		exit 
	fi
else 
	echo "apr-util ./configure error ! exit "
	exit 
fi
#install pcre
echo "start instal pcre "
echo "current directory is : " `pwd`
cd /root/web/
tar -jvxf /root/web/pcre-8.35.tar.bz2 
PCRE=`ls -al /root/web/ |grep "^d" |grep ".*pcre.*"|awk '{print $9}'` 
echo "find pcre in /root/web/" $PCRE 
[ "$PCRE" == "" ] && echo " pcre unzip error ! exit " && exit 
echo "pcre : "$PCRE
cd /root/web/$PCRE
echo "enter pcre: " $PCRE
./configure --prefix=/usr/local/pcre
if [ "$?" ==  0 ];then
	make && make install 
	if [ "$?" == 0 ]; then 
		echo "pcre install success"
	else 
		echo "pcre make && make install error ! exit "
		exit 
	fi
else 
	echo "pcre ./configure error ! exit "
	exit 
fi
#apache install
cd /root/web/
tar -jvxf /root/web/httpd-2.4.10.tar.bz2
HTTPD=`ls -al /root/web/ |grep "^d" |grep ".*httpd.*"|awk '{print $9}'` 
[ "$HTTPD" == "" ] && echo " httpd unzip error ! exit " && exit 
cd /root/web/$HTTPD
./configure --prefix=/usr/local/httpd --enable-so --enable-rewrite --enable-cgi --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util/ --with-pcre=/usr/local/pcre/
if [ "$?" ==  0 ];then
	make && make install 
	if [ "$?" == 0 ]; then 
		echo "httpd install success"
	else 
		echo "httpd make && make install error ! exit "
		exit 
	fi
else 
	echo "httpd ./configure error ! exit "
	exit 
fi
