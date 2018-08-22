#!/bin/bash
# Script to download your pdf documents from your CiteULike account
# Copyright (C) 2018 Pieter Smets - All Rights Reserved
# Permission to copy and modify is granted under the MIT license
# Last revised 17/08/2018

echo
echo "  Download your pdf documents from your CiteULike account"
echo
echo "  Export your CiteULike library as a BibTeX file"
echo "  Make sure you ticked the box \"Yes, export attachment names\""
echo
echo "  Already existing documents in the output folder are skipped."
echo

# Get credentials
echo "* Your CiteULike..."
echo -n "  ...username: "; read -r username
echo -n "  ...password: "; read -s password
echo

# Log in to the server.  This only needs to be done once.
echo -n "* Log in to CiteULike... "
cookies="/tmp/.${username}.cookies"
log="/tmp/.${username}.log"
wget --save-cookies $cookies \
     --keep-session-cookies \
     --delete-after \
     --post-data "username=$username&password=$password" \
     http://www.citeulike.org/login.do > $log 2>&1

if [ $? -ne 0 ]; then
   echo "failed"
   echo "Error: Could not connect to CiteULike."
   exit $ERROR_CODE
else
   check=$(cat $log | grep "status=login-failed")
   if [[ ! -z $check ]]; then
      echo "failed"
      echo "Error: Could not log in to CiteULike (wrong username/password)."
      exit 1
   else
      echo "done"
   fi
fi

# check if bibliography exists
bib="${username}.bib"
if [ ! -f "$bib" ]; then
   echo "Error: CiteULike library $bib not found!"
   exit 1
fi

# make output folder
fold="${username}_pdf"
echo -n "* Create pdf output folder $fld... "
mkdir -p $fold

if [ $? -ne 0 ]; then
   echo "failed"
   echo "Error: Could not create output folder."
   exit $ERROR_CODE
else
   echo "done"
fi

# get the filenames, urls and hashes from the bibliography
list="/tmp/${username}.list"
echo -n "* Extract pdf filelist from BibTex $bib... "
cat $bib | grep "citeulike-attachment" | sed -e 's/\(^.*= {\)\(.*\)\(},.*$\)/\2/' | sed -e 's/;//g' | awk '{printf "http://www.citeulike.org%s?hash=%s %s\n", $2,$3,$1;}' > $list
echo "done"

# grap all pdf
echo -n "* Download all pdf documents... "
while read -r url name; do
   if [ ! -f $fold/$name ]; then
      wget --load-cookies $cookies -q -O $fold/$name $url
   fi
done < $list

if [ $? -ne 0 ]; then
   echo "failed"
   echo "Error: Could not download pdf files."
   exit $ERROR_CODE
else
   echo "done"
fi

# clean and exit
rm $list $cookies
exit 0
