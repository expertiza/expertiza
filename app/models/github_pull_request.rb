class GithubPullRequest 
  # < Metric
  require 'rest-client'
  require 'json'

  attr_accessor :url
  attr_accessor :data

  def initialize(params)
    @url = params["url"]
    @data = Array.new
  end

  def fetch_content
    result = GithubPullRequest.fetch(@url) 
    @data = result
  end

  class << self
    PR_REGEX = /http[s]{0,1}:\/\/github\.com\/(?'username'[^[\/]]+)\/(?'reponame'[^\/]+)\/pull\/(?'prnum'\d+)/


    def supports_url?(url)
      lower_case_url = url.downcase
      PR_REGEX.match(lower_case_url).nil?
    end

    def fetch(url)
      lower_case_url = url.downcase
      url_parsed = PR_REGEX.match(lower_case_url)
      user_name = url_parsed['username']
      repo_name = url_parsed['reponame']
      pr_number = url_parsed['prnum']
      query = "{ \"query\" : \"#{build_gquery(user_name, repo_name, pr_number)}\"}"
      token = "e280c0295a9b9e069fd233303056b99d07fa34bb"
  
      res = RestClient.post("https://api.github.com/graphql",
        query, :authorization => "Bearer #{token}") { |response, request, result|
        case response.code
        when 200
          json = JSON.parse(response.body)
          pull_request = get_data(json, ["data", "repository", "pullRequest"])
          commits_list = Array.new
   
          if not pull_request.nil?
            commits = get_data(pull_request, ["commits", "nodes"])

            for commit in commits
              name = get_data(commit, ["commit", "committer", "name"])
              email = get_data(commit, ["commit", "committer", "email"])
              date = get_data(commit, ["commit", "committedDate"])

              commits_list.push({ :date => date, :name => name, :email => email })
            end
            commits_list
          end
        else
          raise Error("Respond not returned")
        end
      }
    end

    private

    
    def build_gquery(user_name, repo_name, pr_number)
        "query { repository(name: \\\"expertiza\\\", owner: \\\"expertiza\\\") { pullRequest(number: 955) { number commits(first: 100) { nodes { commit { oid commitUrl committedDate committer { avatarUrl date email name } } } } } } }"
    end
  
    def get_data(tree, array)
      pointer = tree

      for a in array
        if pointer.has_key?(a)
          pointer = pointer.fetch(a)
        else
          pointer = nil
          break
        end
      end
  
      pointer
    end
  end
end