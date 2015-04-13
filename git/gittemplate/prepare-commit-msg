#!/bin/bash

BRANCH_NAME=$(git symbolic-ref --short HEAD)
BRANCH_NAME="${BRANCH_NAME##*/}"

ISSUE_ID=$(echo $BRANCH_NAME | sed 's/^[a-z\-]*-//I')
IS_NUMBER='^[0-9]+$'

if [ -n "$BRANCH_NAME" ] && [[ $ISSUE_ID =~ $IS_NUMBER ]]; then 
  sed -i.bak -e "1s/^/\n\nrefs #$ISSUE_ID /" $1
fi
