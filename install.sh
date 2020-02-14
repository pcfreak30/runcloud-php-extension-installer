#!/usr/bin/env bash

# Version: 0.1.0

EXTENSION=$1
VERSION=$2
if [ -z "$3" ]; then
	PHP_VERSION=(70 71 72 73 74)
else
	PHP_VERSION=("${3/\./}")
fi

if [ -z "$EXTENSION" ]; then
  echo Extension name missing
  exit
fi

if [ -z "$VERSION" ]; then
  echo Extension version missing
  exit
fi

cd /tmp || (echo Failed to move to tmp && exit)
wget https://pecl.php.net/get/"$EXTENSION"-"$VERSION".tgz
tar -zxvf "$EXTENSION"-"$VERSION".tgz
cd "$EXTENSION-$VERSION" || (echo Failed to move to xdebug build folder && exit)

for version in "${PHP_VERSION[@]}"; do
	make clean
	/RunCloud/Packages/php"${version}"rc/bin/phpize --clean
	/RunCloud/Packages/php"${version}"rc/bin/phpize
	./configure --with-libdir=lib64 CFLAGS='-O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wall -pedantic -fsigned-char -fno-strict-aliasing' --with-php-config=/RunCloud/Packages/php"$version"rc/bin/php-config
	make install

	EXT_CONFIG=""

	if [ "$EXTENSION" == "xdebug" ]; then
	  EXT_CONFIG="zend_"
	fi

	EXT_CONFIG="${EXT_CONFIG}extension=$EXTENSION.so"

	echo "$EXT_CONFIG" > /etc/php"$version"rc/conf.d/"$EXTENSION".ini
done

rm /tmp/"$EXTENSION"-"$VERSION" -rf
