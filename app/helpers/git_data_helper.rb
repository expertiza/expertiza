require 'rest-client'
require 'json'
module GitDataHelper
BASE_API = "https://api.github.com"
Access_Token = "token 5cc54d89c18818537da73f0ee4b680c2f219536f"

def fetchPulls(owner, repo)
  resource = RestClient::Resource.new( "#{BASE_API}/repos/#{owner}/#{repo}/pulls?state=all")
  response = resource.get(:Authorization => Access_Token)
  if response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
  else
      return nil
  end
end

def fetchCommits(owner, repo, pull)
  resource = RestClient::Resource.new( "#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{pull}/commits")
  response = resource.get(:Authorization => Access_Token)
  if response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
  else
    return nil
  end
end

def fetchFiles(owner, repo, pull)
  resource = RestClient::Resource.new( "#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{pull}/files")
  response = resource.get(:Authorization => Access_Token)
  if response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
  else
    return nil
  end
end

def fetchPullByNumber(owner, repo, pull)
  resource = RestClient::Resource.new( "#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{pull}")
  response = resource.get(:Authorization => Access_Token)
  if response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
  else
    return nil
  end
end

def fetchCommit(owner, repo, sha)
  resource = RestClient::Resource.new( "#{BASE_API}/repos/#{owner}/#{repo}/commits/#{sha}")
  response = resource.get(:Authorization => Access_Token)
  if response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
  else
    return nil
  end
end
end
