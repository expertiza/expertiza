require 'rest-client'
require 'json'

module GitDataHelper
BASE_API = "https://api.github.com"
Access_Token = "token #{ENV['EXPERTIZA_GITHUB_TOKEN']}".freeze

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
