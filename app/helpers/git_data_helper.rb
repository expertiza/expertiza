require 'rest-client'
require 'json'

module GitDataHelper
  BASE_API = "https://api.github.com".freeze
  ACCESS_TOKEN = 'token %s'%ENV['EXPERTIZA_GITHUB_TOKEN']

  def self.fetch_pulls(owner, repo)
    fetch("#{BASE_API}/repos/#{owner}/#{repo}/pulls?state=all")
  end

  def self.fetch_commits(owner, repo, commit_pull)
    fetch("#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{commit_pull}/commits")
  end

  def self.fetch_files(owner, repo, file_pull)
    fetch("#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{file_pull}/files")
  end

  def self.fetch_pull_by_number(owner, repo, pull)
    fetch("#{BASE_API}/repos/#{owner}/#{repo}/pulls/#{pull}")
  end

  def self.fetch_commit(owner, repo, sha)
    fetch("#{BASE_API}/repos/#{owner}/#{repo}/commits/#{sha}")
  end

  def self.fetch(api)
    resource = RestClient::Resource.new(api)
    response = resource.get(Authorization: ACCESS_TOKEN)
    return nil unless response.code == 200
    JSON.parse(response, object_class: OpenStruct)
  end
end
