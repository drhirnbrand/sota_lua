#!/bin/bash -e

function package() {
  if [ ! -f PACKAGE ]; then
    echo "Skipping package in `pwd`"
    return 0
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

  dir=build/${PACKAGE}-${VERSION}
  zip=build/${PACKAGE}-${VERSION}.zip

  rm -vf ${zip}

  rm -rf ${dir}
  mkdir -v -p ${dir}

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
}

find -type d -maxdepth 1 -name "*drh_sota_*" | {
  while read pkg; do
    (
      cd $pkg
      package
    )
  done
}

