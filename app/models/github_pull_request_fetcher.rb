class GithubPullRequestFetcher
  require 'rest-client'
  require 'json'

  attr_accessor :url
  attr_accessor :number
  attr_accessor :user
  attr_accessor :repo
  attr_accessor :commits

  PR_REGEX = /http[s]{0,1}:\/\/github\.com\/(?'username'[^[\/]]+)\/(?'reponame'[^\/]+)\/pull\/(?'prnum'\d+)/
  GRAPHQL_URL="https://api.github.com/graphql"
  API_URL="https://api.github.com/repos"

  class << self
    def supports_url?(url)
      lower_case_url = url.downcase
      PR_REGEX.match(lower_case_url).nil?
    end
  end

  def initialize(params)
    @url = params["url"]
    @token = "160f081f56892c7950299bdb0223af83a20c132d"
    @loaded = false
  end

  def is_loaded?
    @loaded
  end

  def fetch_content
    lower_case_url = @url.downcase
    url_parsed = PR_REGEX.match(lower_case_url)
    @user = url_parsed['username']
    @repo = url_parsed['reponame']
    @number = url_parsed['prnum']
    @commits = fetch_pr_commits_data()
    @loaded = true
  end

  private

  def fetch_pr_commits_data(page_info = {}, commits_list = Array.new)
    after_query = build_after_query(page_info) 
    query = build_github_pr_query(@user, @repo, @number, after_query)

    RestClient.post(GRAPHQL_URL, query, :authorization => "Bearer #{@token}") { |response, request, result|
      case response.code
      when 200
        json = JSON.parse(response.body)
        pull_request = get_data(json, ["data", "repository", "pullRequest"])
        if not pull_request.nil?
          page_info = get_data(pull_request, ["commits", "pageInfo"])
          commits = get_data(pull_request, ["commits", "nodes"])

          for commit in commits
            oid = get_data(commit, ["commit", "oid"])
            name = get_data(commit, ["commit", "committer", "name"])
            email = get_data(commit, ["commit", "committer", "email"])
            date = get_data(commit, ["commit", "committedDate"])
            stats = fetch_commit_stats_data(@user, @repo, oid, @token)

            commits_list.push({ 
              :date => date, 
              :name => name, 
              :email => email, 
              :stats => stats })
          end
          puts commits_list
          if page_info["hasNextPage"] == "true"
            fetch_pr_data(page_info, commits_list) 
          else
            { :data => commits_list }
          end
        end
      else
        { :error => "Error loading commits list", :data => commits_list }
      end
    }
  end

  def fetch_commit_stats_data(user_name, repo_name, commit_hash, token) 
    RestClient.get(
      "#{API_URL}/#{user_name}/#{repo_name}/commits/#{commit_hash}", 
      :authorization  => "Bearer #{token}") { | response, request, result|
      case response.code
      when 200
        json = JSON.parse(response.body)
        get_data(json, ["stats"])
      else
        { :error => "Error loading commit stats" }
      end
    }
  end

  def build_github_pr_query(user_name, repo_name, pr_number, after_query = "")
    query = <<-EOS.gsub(/^[\s\t]*|[\s\t]*\n/, ' ') 
    query { 
      repository(
        name: \\\"#{repo_name}\\\", 
        owner: \\\"#{user_name}\\\") 
        { 
          pullRequest(number: #{pr_number})  
          { 
              number 
              commits(first: 250 #{after_query}) 
              { 
                nodes 
                { 
                  commit { 
                    oid commitUrl committedDate committer 
                    { 
                      avatarUrl date email name 
                    } 
                } 
              }
              pageInfo {
                endCursor hasNextPage
              } 
            } 
          } 
        } 
      }
      EOS
    "{ \"query\" : \"#{query}\"}"
  end

  def build_after_query(page_info) 
    if page_info["hasNextPage"] == "true"
      "after:\\\"#{page_info.endCursor}\\\""
    else
      ""
    end
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
