require 'uri'
require 'open-uri'
require "json"
require "time"

WIKIPEDIA_PUB = "en.wikipedia.org"
WIKIPEDIA_NCSU = "wiki.expertiza.ncsu.edu"
GITHUB_PUB = "github.com"

WIKIPEDIA_NCSU_API_BASE_PATH = "/api.php?action=query&prop=revisions&format=json&rvprop=timestamp&titles="
WIKIPEDIA_PUB_API_BASE_PATH = "/w/api.php?action=query&prop=revisions&format=json&rvprop=timestamp&titles="

class TrackHyperlink
  def initialize(hyperlink)
  	@hyperlink = hyperlink
  end
  	
  def retrieve_modify_timestamp()
    uri = URI(@hyperlink)
    if uri.host == WIKIPEDIA_PUB || uri.host == WIKIPEDIA_NCSU
	  retrieve_wikipedia_timestamp(uri)
	elsif uri.host == GITHUB_PUB
	  retrieve_github_pub_timestamp(uri)
	else #can't check update timestamps for unknown link types
	  return nil
	end
  end
  
  #JSON format expected from wikipedia is as follows
  #{
  #	"query" => {
  #		"normalized" => [{
  #			"from" => "CSC/ECE_517_Fall_2015/ossE1568BZHXJS", "to" => "CSC/ECE 517 Fall 2015/ossE1568BZHXJS"
  #		}], "pages" => {
  #			"7072" => {
  #				"pageid" => 7072, "ns" => 0, "title" => "CSC/ECE 517 Fall 2015/ossE1568BZHXJS", "revisions" => [{
  #					"timestamp" => "2015-11-04T02:59:50Z"
  #				}]
  #			}
  #		}
  #	}
  #}
  def retrieve_wikipedia_timestamp(uri)
    path = uri.path
    path.sub!(/\/wiki\//, '') if path.start_with?("/wiki/")	#for public wikipedia
    path.sub!(/\/index.php\//, '') if path.start_with?("/index.php/")  #for ncsu wikipedia
    page_title = path
    page_title = URI::encode(page_title)
	req_path = ""
    if uri.host == WIKIPEDIA_PUB
      req_path = WIKIPEDIA_PUB_API_BASE_PATH + page_title
	else
      req_path = WIKIPEDIA_NCSU_API_BASE_PATH + page_title
	end
    req_uri = uri.scheme + "://" + uri.host + req_path
    #Hoping no redirects
	#TODO find some way to handle parsing and url open errors besides just ignoring exception
    response = open(req_uri).read
    parsed_resp = JSON.parse(response)
	#some timestamp like "2015-11-28T08:44:32Z" is expected here, which is standard ISO time format
	if parsed_resp["query"]["pages"].keys[0] != "-1"  #-1 => page not found
      update_time_iso = parsed_resp["query"]["pages"][parsed_resp["query"]["pages"].keys[0]]["revisions"][0]["timestamp"]
	else
	  return nil
	end
  end

  def retrieve_github_pub_timestamp(uri)
  end

end
