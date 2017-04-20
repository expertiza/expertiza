require 'http'

BASE_URI = 'https://api.github.com'
API_TOKEN = 'token %s'%ENV['EXPERTIZA_GITHUB_TOKEN']


def fetch_metrics(owner, repo)
  resp = HTTP.headers(Authorization: API_TOKEN).get("#{BASE_URI}/repos/#{owner}/#{repo}/stats/contributors")
  if resp.code == 200
    return resp.parse
  else
    return nil
  end
end

puts fetch_metrics('asorgiu', 'expertiza')

module GithubMetricsHelper

end

