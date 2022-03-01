#!/bin/bash

if [ -z "$1" ]; then
    echo "waiting for the following arguments: username + max-page-number"
    exit 1
else
    name=$1
fi

if [ -z "$2" ]; then 
    declare -i max=2
else
    declare -i max=$2
fi

#cntx="users"
cntx="orgs"
declare -i page=1

echo $name
echo $max
echo $cntx
echo $page

while (( $page <= $max ))
do 
    echo "Download page $page"
    curl "https://api.github.com/$cntx/$name/repos?page=$page&per_page=30" | jq '.[].git_url' | xargs -L1 git clone

    sleep $[ ( $RANDOM % 10 )  + 1 ]s # Random sleep
    page=$page+1
done

exit 0
