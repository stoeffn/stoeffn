#!/bin/bash

if
    [ $# -eq 0 ]
then
    echo "Error: Version name is a required argument." >&2
    exit 1
fi

version=$1
description=$2

cd public

deployedTags=`git tag`

if
    [[ $deployedTags = *$version* ]]
then
    echo "Info: Version \"$version\" is already deployed." >&2
    exit 1
fi

rm -rf public

cd ..
hugo

cd public

git add .
git commit -m ":rocket: Deploy $version" -m "$description"
git tag -a "$version" -m "$description"

git push
git push --follow-tags

cd ..
git add public
git commit -m ":rocket: Deploy $version" -m "$description"
git tag -a "$version" -m "$description"

git push
git push --follow-tags
