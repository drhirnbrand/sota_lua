#!/bin/bash -e

if [ ! -f PACKAGE ]; then
  exit 1
fi

PACKAGE=`cat PACKAGE`
VERSION=`cat VERSION`

echo "Packaging ${PACKAGE} Version ${VERSION}"

if [ ! -n ${PACKAGE} ]; then
  exit 1
fi
if [ ! -n ${VERSION} ]; then
  exit 1
fi

rm -vf ${PACKAGE}-${VERSION}.zip

mkdir -v ${PACKAGE}.build

for file in `cat package.list`; do
  cp -v ${file} ${PACKAGE}.build
done

for script in ${PACKAGE}.build/*.lua; do
  sed -i s@%%%VERSION%%%@$
(
  cd ${PACKAGE}.build
  zip -u -r ${PACKAGE}-${VERSION}.zip *
)


