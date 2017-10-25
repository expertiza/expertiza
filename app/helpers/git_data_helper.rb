require 'rest-client'
require 'json'

module GitDataHelper
  BASE_API = "https://api.github.com"
  Access_Token = "token ecc81cdcd383f66211dc05d1a000b0b0253b7133"

  def self.fetch_Pulls(owner, repo)
    return fetch("#{BASE_API}/repos/#{owner}/#{repo}/pulls?state=all")
  end

  def self.fetch_Commits(owner, repo, pull)
    return fetch("#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{pull}/commits")
  end

  def self.fetch_Files(owner, repo, pull)
    return fetch("#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{pull}/files")
  end

  def self.fetch_Pull_By_Number(owner, repo, pull)
    return fetch("#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{pull}")
  end

  def self.fetch_Commit(owner, repo, sha)
    return fetch("#{BASE_API}/repos/#{owner}/#{repo}/commits/#{sha}")
  end

  def self.fetch(api)
    resource = RestClient::Resource.new(api)
    response = resource.get(Authorization: Access_Token)
    return nil unless response.code == 200
    return JSON.parse(response, object_class: OpenStruct)
end
end
