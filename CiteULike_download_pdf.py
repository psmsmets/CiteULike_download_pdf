#!/usr/env python
# Script to download your pdf documents from your CiteULike account
# Copyright (C) 2018 Pieter Smets - All Rights Reserved
# Permission to copy and modify is granted under the MIT license
# Last revised 20/08/2018

import requests, getpass
import sys, os, errno
import progressbar

print ("Download your pdf documents from your CiteULike account\n")
print ("Export your CiteULike library as a BibTeX file")
print ("Make sure you ticked the box \"Yes, export attachment names\"\n")
print ("Already existing documents in the output folder are skipped.\n")

#####
print("Your CiteULike...")
####
user = str(input("  ...username: "))
pswd = getpass.getpass('  ...password: ')
baseurl = 'http://www.citeulike.org'

#####
print("Log in to CiteULike ")
#####
session = requests.session()
r = session.post(baseurl+'/login.do', data = {'username':user,'password':pswd})
r.raise_for_status()
if r.url == baseurl:
    print('succesfully logged in')
elif "status=login-failed" in r.url:
    raise Exception('Wrong password')
    
#####
bib = input("Define BibTex file (default = " + user + ".bib) : ") or user+".bib"
print("Scan BibTex file", bib)
####
if not os.path.exists(bib):
    raise Exception('Error: CiteULike BibTex library not found!')

#####
dest = os.path.join( os.path.dirname(bib), user + "_pdf")
print("Generate output folder for pdf documents : ", dest)
#####
try:
    os.makedirs(dest)
except OSError as e:
    if e.errno != errno.EEXIST:
        raise
        
#####
print("Extract documents from BibTex library")
#####
with open(bib,"r") as fi:
    pdflist = []
    for ln in fi:
        ln=ln.strip()
        if ln.startswith("citeulike-attachment"):
            pdflist.append(ln.split('{')[1].split('}')[0].split('; '))

#####
print("Download your CiteULike pdf documents")
#####
bar = progressbar.ProgressBar(max_value=len(pdflist)-1)
i = -1
for pdf in pdflist:
    i+=1; bar.update(i)
    f = os.path.join(dest,pdf[0])
    u = baseurl+pdf[1]+"?hash="+pdf[2]
    r = session.get(u)
    with open(f, 'wb') as f:  
        f.write(r.content)

# close session
session.close;
