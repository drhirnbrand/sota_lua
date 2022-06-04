#!/bin/bash

source .local

PATH=/cygdrive/e/github-cli/:$PATH
export PATH

tag=`date +%Y%m%dT%H%M`

echo "Release Tag: ${tag}"

zipfiles=`find -name "*.zip"`

echo -e "Zip Files:\n${zipfiles}"

git status || exit 1

exit 0

git tag ${tag}
git push --tags

gh release create ${tag} --draft ${zipfiles}