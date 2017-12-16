
module UpdateDetectorHelper
  require 'octokit' # Use this gem with Github API operations
  require 'uri'

  def update?(response)
    @last_review_time = response.updated_at
    @team = response.map.contributor

    # check update for both submission content(include links and files) and link-to content
    submission_updated? || link_to_content_updated?
  end

  def submission_updated?
    @latest_submission_time = nil
    @submission_records = SubmissionRecord.where(team_id: @team.id)

    record_times = []
    @submission_records.each do |record|
      record_times << record.created_at
    end
    @latest_submission_time = record_times.sort.last

    (@latest_submission_time <=> @last_review_time) == 1
  end

  def link_to_content_updated?
    @link_to_content_update_time = nil
    hyperlinks = @team.hyperlinks

    update_times = []
    hyperlinks.each do |link|
      time = get_link_update_time(link)
      update_times << time unless time.nil?
    end
    @link_to_content_update_time = update_times.sort.last

    (@link_to_content_update_time <=> @last_review_time) == 1
  end

  def get_link_update_time(submitted_link)
    # check validity of link
    url = submitted_link.slice(URI.regexp)
    return nil if url.nil?

    # recognize url type
    parsed_url = URI(url)

    case parsed_url.host
      when /^github(.*)/ # url is a GitHub link
        get_latest_commit_time(parsed_url)
    end
  end

  def get_latest_commit_time(github_url)
    client = Octokit::Client.new
    # client.access_token = ENV['GITHUB_TOKEN']

    case github_url.host
      when 'github.ncsu.edu'
        # client.access_token = ENV['GITHUB_NCSU_TOKEN']
        client.access_token = '8289b47fe8db5c8bceb2f84b2e0c56fc31c5d9e5'
        client.api_endpoint = 'https://github.ncsu.edu/api/v3'
    end

    begin
      path = github_url.path.split('/')
      repo = path[1] + '/' + path[2]
      repo.slice!('.git')
      res = client.commit(repo, 'master')
      return res.to_h[:commit][:author][:date]
    rescue => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
      return Time.new()+(60*60*24)  #define a future time
    end
  end

end
