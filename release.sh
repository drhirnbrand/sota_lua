#!/bin/bash

source .local

PATH=/cygdrive/e/github-cli/:$PATH
export PATH

tag=`date +%Y%m%dT%H%M`

echo "Release Tag: ${tag}"

zipfiles=`find -name "*.zip"`

echo -e "Zip Files:\n${zipfiles}"

git diff-index --quiet HEAD; retval=?

if [ "${retval}" != "0" ]; then
  echo "Uncommited changes in repository!"
  exit 1
fi

exit 0

git tag ${tag}
git push --tags

gh release create ${tag} --draft ${zipfiles}
