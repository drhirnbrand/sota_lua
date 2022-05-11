#!/bin/bash -e

if [ ! -f PACKAGE ]; then
  exit 1
fi

PACKAGE=`cat PACKAGE`
VERSION=`cat VERSION`

echo "Packaging ${PACKAGE} Version ${VERSION}"

if [ ! -n "${PACKAGE}" ]; then
  exit 1
fi
if [ ! -n "${VERSION}" ]; then
  exit 1
fi

dir=${PACKAGE}-${VERSION}
zip=${PACKAGE}-${VERSION}.zip

rm -vf ${zip}

rm -rf ${dir}
mkdir -v ${dir}

for file in `cat package.list`; do
  cp -v ${file} ${dir}
done

for script in ${dir}/*.lua; do
  echo "Updating ${script}"
  sed -i s@%%%VERSION%%%@${VERSION}@ ${script}
done

zip -u -r ${zip} ${dir}
