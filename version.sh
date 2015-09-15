#!/bin/bash

VERSION=$1
echo Setting version to $VERSION
npm version $VERSION
bower version $VERSION

echo Bower version:
grep version bower.json
echo NPM version:
grep version package.json

