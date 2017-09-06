class GithubPullRequest < Metric
  require 'http_request'
  require 'json'

  pr_regex = /http[s]{0,1}:\/\/github\.com\/(?'username'[^[\/]+)\/(?'reponame[^\/]+)\/pull\/(?'prnum'\d+)/

  def get_data(tree, array)
    pointer = tree

    for a in array
      if pointer.has_key?(a)
        pointer = json(a)
      else
        pointer = nil
        break
      end
    end

    pointer
  end

  def fetch_data(url)
    url_parsed = pr_regex.match(url)
    user_name = url_parsed['username']
    repo_name = url_parsed['reponame']
    pr_number = url_parsed['prnum']

    res = HttpRequest.get("query { repository(name: \"#{user_name}\", owner: \"#{repo_name}\") { pullRequest(number: #{pr_number}) { number commits(first : 100) { nodes { commit committedDate { oid commitUrl committer { avatarUrl date email name } } } } } } }")

    if res.is_a? Net::HTTPSuccess
      json = JSON.parse(res.body)
      pull_request = get_data(json, ["data", "respository", "pullRequest"])

      if not pullRequest.nil?
        commits = get_data(pull_request, ["nodes"])

        for commit in commits
          if commit.has_key? "committer"
            commit["commiter"]["name"]
            commit["commiter"]["email"]
          end
        end
      end
    else
      raise Error("Respond not returned")
    end
  end
end
