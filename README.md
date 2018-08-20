# CiteULike_download_pdf

Download all your pdf documents from your CiteULike account 

First export your CiteULike library as a BibTeX file. Make sure you ticked the box "Yes, export attachment names".

You can run either the bash or python3 script to download your documents.

	CiteULike_download_pdf.sh
	CiteULike_download_pdf.py

The script asks for your CiteULike username and password to initiate an http session.

All pdf documents are stored in the folder "USERNAME_pdf". Already existing documents in the output folder are skipped.


Your BibTex file and folder with pdf documents are now ready to be imported imported in Mendeley (desktop).
