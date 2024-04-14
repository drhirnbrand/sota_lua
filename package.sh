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

  rm -v -rf build
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

  cp -v drh_sota_library/drh_sota_library.lua ${dir}

  # Create zip, get full path, remove, then final package
  touch ${zip}
  zipfullname="$(readlink -f ${zip})"
  rm -f ${zip}

  (
    cd ${dir} && zip -v -u -r ${zipfullname} ./*
  )
}

find -maxdepth 1 -type d  -name "*drh_sota_*" | {
  while read pkg; do
    (
      cd $pkg
      package
    )
  done
}

