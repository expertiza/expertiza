class GithubMetricsFetcher
  require 'rest-client'
  require 'json'

  attr_accessor :url
  attr_accessor :number
  attr_accessor :user
  attr_accessor :repo
  attr_accessor :commits

  SOURCES = [ 
    { REGEX: /http[s]{0,1}:\/\/github\.com\/(?'username'[^[\/]]+)\/(?'reponame'[^\/]+)\/pull\/(?'prnum'\d+)/,
      GRAPHQL: "https://api.github.com/graphql",
      API: "https://api.github.com/repos",
      FUNCTION: :fetch_pr_commits_data,
      TOKEN: "010c619b17d1fa8fd7d7991726cc47c89577b8dc"
    },
    { REGEX: /http[s]{0,1}:\/\/github\.com\/(?'username'[^[\/]]+)\/(?'reponame'[^\/]+)/,
      GRAPHQL: "https://api.github.com/graphql",
      API: "https://api.github.com/repos",
      FUNCTION: :fetch_project_data,
      TOKEN: "010c619b17d1fa8fd7d7991726cc47c89577b8dc"
    },
    { REGEX: /http[s]{0,1}:\/\/github\.ncsu\.edu\/(?'username'[^[\/]]+)\/(?'reponame'[^\/]+)\/pull\/(?'prnum'\d+)/,
      GRAPHQL: "https://api.github.ncsu.edu/graphql",
      API: "https://api.github.ncsu.edu/repos",
      FUNCTION: :fetch_pr_commits_data,
      TOKEN: "5f8debd4c7199535d2ef2a91cb9b46f41e84c5d0"
    },
    { REGEX: /http[s]{0,1}:\/\/github\.ncsu\.edu\/(?'username'[^[\/]]+)\/(?'reponame'[^\/]+)/,
      GRAPHQL: "https://api.github.ncsu.edu/graphql",
      API: "https://api.github.ncsu.edu/repos",
      FUNCTION: :fetch_project_data,
      TOKEN: "5f8debd4c7199535d2ef2a91cb9b46f41e84c5d0"
    }
  ]

  class << self
    def supports_url?(url)
      if not url.nil?
        lower_case_url = url.downcase
        params = SOURCES.find { | params | params[:REGEX].match(lower_case_url).nil? }
        ! params.is_empty?
      else 
        false
      end
    end
  end

  def initialize(params)
    @url = params["url"]
    @loaded = false
  end

  def is_loaded?
    @loaded
  end

  def fetch_content
    lower_case_url = @url.downcase
    params = SOURCES.find { | params | ! params[:REGEX].match(lower_case_url).nil? }
    url_parsed = params[:REGEX].match(lower_case_url)
    @user = url_parsed['username']
    @repo = url_parsed['reponame']

    if url_parsed.names.include?('prnum')
      @number = url_parsed['prnum']
    end

    @commits = self.send(params[:FUNCTION], params)
    @loaded = true
  end

  private

  def fetch_project_data(params)
    query = build_github_project_query(@user, @repo)
    RestClient.post(params[:GRAPHQL], query, :authorization => "Bearer #{params[:TOKEN]}") { |response, request, result|
      case response.code
      when 200
        json = JSON.parse(response.body)
        created_at = get_data(json, ["data", "repository", "createdAt"])
        is_fork = get_data(json, ["data", "repository", "isFork"])
        since = "since:\\\"#{created_at}\\\""

        fetch_project_commits_data(params, since)
      else
        { :error => "Error loading project #{response.code}", :data => [] }
      end
    }
  end

  def fetch_project_commits_data(params, since, page_info = {}, commits_list = Array.new)
    after_query = build_after_query(page_info) 
    query = build_github_project_commits_query(@user, @repo, since, after_query)

    RestClient.post(params[:GRAPHQL], query, :authorization => "Bearer #{params[:TOKEN]}") { |response, request, result|
      case response.code
      when 200
        json = JSON.parse(response.body)
        page_info = get_data(json, ["data", "repository", "ref", "target", "history", "pageInfo"])
        commits = get_data(json, ["data", "repository", "ref", "target", "history", "edges"])
        if not commits.nil?
          for commit in commits
            oid = get_data(commit, ["node", "oid"])
            name = get_data(commit, ["node", "author", "name"])
            email = get_data(commit, ["node", "author", "email"])
            date = get_data(commit, ["node", "committedDate"])
            stats = fetch_commit_stats_data(params, @user, @repo, oid)

            commits_list.push({ 
              :date => date, 
              :name => name, 
              :email => email, 
              :stats => stats })
          end
          if page_info["hasNextPage"] == "true"
            fetch_pr_data(params, page_info, commits_list) 
          else
            { :data => commits_list }
          end
        end
      else
        { :error => "Error loading commits list #{response.code}", :msg => response.body, :data => commits_list }
      end
    }
  end

  def fetch_pr_commits_data(params, page_info = {}, commits_list = Array.new)
    after_query = build_after_query(page_info) 
    query = build_github_pr_query(@user, @repo, @number, after_query)

    RestClient.post(params[:GRAPHQL], query, :authorization => "Bearer #{params[:TOKEN]}") { |response, request, result|
      case response.code
      when 200
        json = JSON.parse(response.body)
        pull_request = get_data(json, ["data", "repository", "pullRequest"])
        if not pull_request.nil?
          page_info = get_data(pull_request, ["commits", "pageInfo"])
          commits = get_data(pull_request, ["commits", "nodes"])

          for commit in commits
            oid = get_data(commit, ["commit", "oid"])
            name = get_data(commit, ["commit", "author", "name"])
            email = get_data(commit, ["commit", "author", "email"])
            date = get_data(commit, ["commit", "committedDate"])
            stats = fetch_commit_stats_data(params, @user, @repo, oid)

            commits_list.push({ 
              :date => date, 
              :name => name, 
              :email => email, 
              :stats => stats })
          end
          if page_info["hasNextPage"] == "true"
            fetch_pr_data(params, page_info, commits_list) 
          else
            { :data => commits_list }
          end
        end
      else
        { :error => "Error loading commits list #{response.code}", :msg => response.body, :data => commits_list }
      end
    }
  end

  def fetch_commit_stats_data(params, user_name, repo_name, commit_hash) 
    RestClient.get(
      "#{params[:API]}/#{user_name}/#{repo_name}/commits/#{commit_hash}", 
      :authorization  => "Bearer #{params[:TOKEN]}") { | response, request, result|
      case response.code
      when 200
        json = JSON.parse(response.body)
        get_data(json, ["stats"])
      else
        { :error => "Error loading commit stats" }
      end
    }
  end

  def build_after_query(page_info) 
    if page_info["hasNextPage"] == "true"
      "after:\\\"#{page_info.endCursor}\\\""
    else
      ""
    end
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
              commits(first: 100 #{after_query}) 
              { 
                nodes 
                { 
                  commit { 
                    oid commitUrl committedDate 
                    author
                    { 
                      date email name 
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

  def build_github_project_query(user_name, repo_name)
    query = <<-EOS.gsub(/^[\s\t]*|[\s\t]*\n/, ' ')
    query { 
      repository(
        name: \\\"#{repo_name}\\\", 
        owner: \\\"#{user_name}\\\") 
        { 
          isFork
          createdAt
        }
    }
    EOS

    "{ \"query\" : \"#{query}\"}"
  end

  def build_github_project_commits_query(user_name, repo_name, since, after_query = "")
    query = <<-EOS.gsub(/^[\s\t]*|[\s\t]*\n/, ' ') 
    query { 
      repository(
        name: \\\"#{repo_name}\\\", 
        owner: \\\"#{user_name}\\\") 
        { 
          ref(qualifiedName: \\\"master\\\") {
            target {
              ... on Commit {
                id
                history(first: 100 #{since} #{after_query}) {
                  pageInfo {
                    endCursor hasNextPage
                  }
                  edges {
                    node {
                      oid commitUrl committedDate 
                      author
                      { 
                        date email name 
                      }  
                    }
                  }
                }
              }
            }
          }
        } 
      }
      EOS
    
    "{ \"query\" : \"#{query}\"}"
  end

  def get_data(tree, array)
    pointer = tree

    for a in array
      if !pointer.nil? and pointer.has_key?(a)
        pointer = pointer.fetch(a)
      else
        pointer = nil
        break
      end
    end

    pointer
  end
end
