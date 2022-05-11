#!/bin/sh -e

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
  echo "Packaging file ${file}"
  tgt="$(echo ${file} | sed s@\\.\\.@@g)"

  if test -d ${file}; then
    echo "Creating Directory: ${file} to ${dir}/${tgt}"
    mkdir ${dir}/${tgt}
  elif test -f ${file}; then
    echo "Copy File: ${file} to ${dir}/${tgt}"
    cp -v ${file} ${dir}/${tgt}
  else
    echo "File does not exist! -> ${file}"
    exit 1
  fi
done

for script in ${dir}/*.lua; do
  echo "Updating ${script}"
  sed -i s@%%%VERSION%%%@${VERSION}@ ${script}
done

zip -u -r ${zip} ${dir}
