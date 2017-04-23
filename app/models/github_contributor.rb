class GithubContributor < ActiveRecord::Base
  BASE_URI = 'https://api.github.com'
  API_TOKEN = 'token %s'%ENV['EXPERTIZA_GITHUB_TOKEN']
  GITHUB_REGEX = /https?:\/\/([w]{3}\.)?github.com\/([A-Z0-9_\-]+)\/([A-Z0-9_\-]+)[\S]*/i


  def fetch_metrics(owner, repo)
    resp = HTTP.headers(Authorization: API_TOKEN).get("#{BASE_URI}/repos/#{owner}/#{repo}/stats/contributors")
    if resp.code == 200
      return resp.parse
    else
      return nil
    end
  end


  def parse_submissions(submission, github_content)
    # TODO: Optimize this call by checking updated timestamp
    GithubContributor.where(submission_records_id: submission.id).destroy_all
    github_contributors = []
    github_content.each do |contributions|
      total = contributions['total']
      user_name = contributions['author']['login']
      github_id = contributions['author']['id']
      contributions['weeks'].each do |week|
        contribution = GithubContributor.new
        contribution.user_name=user_name
        contribution.github_id=github_id
        contribution.total_commits=total
        contribution.lines_changed=week['c']
        contribution.lines_added=week['a']
        contribution.lines_removed=week['d']
        contribution.week_timestamp=Time.at(week['w']).to_s(:db)
        contribution.submission_records_id=submission.id
        github_contributors << contribution
      end
    end
    GithubContributor.import github_contributors
    return github_contributors
  end


  def retrieve_content(submission)
    if submission.operation != 'Submit Hyperlink'
      # || !has_submission_finished(submission)
      return nil
    end
    matches = GITHUB_REGEX.match(submission.content)
    if matches.nil?
      return nil
    end
    return matches[2], matches[3] # Owner, Repo
  end

  def has_submission_finished(submission)
    return Assignment.find(Team.find(submission.team_id).parent_id).current_stage_name == 'Finished'
  end

  def update_submission(submission)
    content = retrieve_content(submission)
    unless content.nil?
      github_data = fetch_metrics(content[0], content[1])
      unless github_data.nil?
        return parse_submissions(submission, github_data)
      end
    end
    nil
  end

end
