require 'rest-client'
require 'json'

module GitDataHelper
BASE_API = "https://api.github.com"
Access_Token = "token 9dc59b866190e57ca7f36e28950d88f19e1a8976"

def self.fetchPulls(owner, repo)
  resource = RestClient::Resource.new( "#{BASE_API}/repos/#{owner}/#{repo}/pulls?state=all")
  response = resource.get(:Authorization => Access_Token)
  if response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
  else
      return nil
  end
end

def self.fetchCommits(owner, repo, pull)
  resource = RestClient::Resource.new( "#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{pull}/commits")
  response = resource.get(:Authorization => Access_Token)
  if response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
  else
    return nil
  end
end

def self.fetchFiles(owner, repo, pull)
  resource = RestClient::Resource.new( "#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{pull}/files")
  response = resource.get(:Authorization => Access_Token)
  if response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
  else
    return nil
  end
end

def self.fetchPullByNumber(owner, repo, pull)
  resource = RestClient::Resource.new( "#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{pull}")
  response = resource.get(:Authorization => Access_Token)
  if response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
  else
    return nil
  end
end

def self.fetchCommit(owner, repo, sha)
  resource = RestClient::Resource.new( "#{BASE_API}/repos/#{owner}/#{repo}/commits/#{sha}")
  response = resource.get(:Authorization => Access_Token)
  if response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
  else
    return nil
  end
end
end
