#!/bin/bash

if [ -e "/tmp/.ssh/id_rsa" ]; then
	cp /tmp/.ssh/id_rsa ~/.ssh/id_rsa
	chmod 400 ~/.ssh/id_rsa
fi

if [ ${DEBUG} = TRUE ]; then
	cat /root/.ssh/config
fi

if [ -d "${GIT_CLONE_PATH}" ]; then
	rm -rf ${GIT_CLONE_PATH}
fi

git config --global user.email "${GIT_USER_EMAIL}"
git config --global user.name "${GIT_USER_NAME}"

git clone --depth 20 --branch ${GIT_BRANCH} ${GIT_CLONE_URL} ${GIT_CLONE_PATH}

# Check if error.
if [ $? -ne 0 ]; then
	exit $?
fi

cd ${GIT_CLONE_PATH}
git checkout ${GIT_AFTER}
git reset ${GIT_AFTER}

if [ ${DEBUG} = TRUE ]; then
	git log --pretty=oneline
fi

FILES=$(git diff --diff-filter=ACMRTUXB --name-only ${GIT_BEFORE} | tr "\\n" " ")

if [ -z "$FILES" ]; then
	exit 1;
fi

$HOME/.composer/vendor/bin/phpcbf --standard=$HOME/.composer/vendor/drupal/coder/coder_sniffer/Drupal --extensions="php,module,inc,install,test,profile,theme,js,css,info,txt" $FILES

git checkout -b phpcs/${GIT_AFTER}

# Check if error.
if [ $? -ne 0 ]; then
        exit $?
fi

# If nothning to fix.
if [[ "$(git status -s | wc -l)" -eq "0" ]]; then
	exit 0
fi

git commit -am "Fix coding standards for commit ${GIT_AFTER}"

# Check if error.
if [ $? -ne 0 ]; then
        exit $?
fi

git push origin phpcs/${GIT_AFTER}

# Check if error.
if [ $? -ne 0 ]; then
        exit $?
fi

hub pull-request -m "Fix coding standards for commit ${GIT_AFTER}" -b ${GIT_BRANCH} -h phpcs/${GIT_AFTER}

# Check if error.
if [ $? -ne 0 ]; then
        exit $?
fi
