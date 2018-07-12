#!/bin/bash

(git clone git@github.com:markchalloner/git-semver.git && cd git-semver && git checkout $( git tag | grep '^[0-9]\+\.[0-9]\+\.[0-9]\+$' | sort -t. -k 1,1n -k 2,2n -k 3,3n | tail -n 1) && sudo ./install.sh)
