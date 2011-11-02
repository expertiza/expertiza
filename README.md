Expertiza - Wiki spider:
Currently in expertiza we have to submit links for wiki pages created.
Our features helps in avoiding this by directly retrieving the URLS from the media wiki servers.
The main API requires the assigment url as http://expertiza.csc.ncsu.edu/wiki/index.php , the assignment id and the user name.
It will crawl the media wiki server for the changes made by that particulr user and list the latest one if it falls within the assigment submission period.

Changes are present in :
wiki_helper.rb
_mediwiki.html.erb