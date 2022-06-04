#!/bin/bash

source .local

PATH=/cygdrive/e/github-cli/:$PATH
export PATH

gh auth status; retval=$?

if [ $retval != "0" ]; then
	echo -e "Trying to login..."
	gh config set prompt disabled
	gh auth login
	echo -e "Done."
else
	echo -e "Already authenticated."
fi


#tag=`date +%Y%m%dT%H%M`
tag="test-0.0.1"

echo "Release Tag: ${tag}"

zipfiles=`find -name "*.zip"`

echo -e "Zip Files:\n${zipfiles}"

git diff-index --quiet HEAD; retval=$?

if [ "${retval}" != "0" ]; then
  echo "Uncommited changes in repository!"
#  exit 1
fi

#git tag ${tag}
#git push --tags

for zipfile in ${zipfiles}; do
  echo "$(dirname $(dirname ${zipfile}))"
done

echo -e "Performing release"
gh release create ${tag} --draft ${zipfiles}


