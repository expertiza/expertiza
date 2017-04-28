class GithubContributorsController < ApplicationController
  def action_allowed?
    # currently we only have a index method which shows all the submission records given a team_id
    @submission_record = SubmissionRecord.find(params[:id])
    return false if @submission_record.operation != 'Submit Hyperlink'
    assignment_team = AssignmentTeam.find(@submission_record.team_id)
    assignment = Assignment.find(assignment_team.parent_id)
    return true if (['Super-Administrator', 'Administrator'].include? current_role_name) ||
                                                                         (assignment.instructor_id == current_user.id)
    return true if TaMapping.exists?(ta_id: current_user.id, course_id: assignment.course_id) &&
        (TaMapping.where(course_id: assignment.course_id).include?
        TaMapping.where(ta_id: current_user.id, course_id: assignment.course_id).first)
    return true if assignment.course_id && Course.find(assignment.course_id).instructor_id == current_user.id
    return false
  end

  def show
    metrics = update_submission(@submission_record)
    matches = GITHUB_REGEX.match(@submission_record.content)
    if metrics.nil?
      if matches.nil?
        @message = 'This is not a github repository.'
      else
        @message = 'Accessed the github API too soon. Refresh the page, if '+
            'it fails again, please contact the administrator.'
      end
      render 'github_contributors/not_found'
    else
      metrics_map = format_metrics(metrics)
      @github_data = {
          metrics_map: metrics_map,
          owner: matches[2],
          repo: matches[3]
      }
      render 'github_contributors/show'
    end
  end

  private

  BASE_URI = 'https://api.github.com'
  API_TOKEN = "token #{ENV['EXPERTIZA_GITHUB_TOKEN']}"
  GITHUB_REGEX = /https?:\/\/([w]{3}\.)?github.com\/([A-Z0-9_\-]+)\/([A-Z0-9_\-]+)[\S]*/i

  def fetch_metrics(owner, repo)
    resp = HTTP.headers(Authorization: API_TOKEN).get("#{BASE_URI}/repos/#{owner}/#{repo}/stats/contributors")
    resp.parse if resp.code == 200
  end

  def parse_submissions(submission, github_content)
    github_contributors = GithubContributor.where(submission_records_id: submission.id).order('created_at DESC')
    if github_contributors.length > 0 &&
        github_contributors.length == github_contributors.where('created_at > ?', Time.now - 1.hour).length
      return github_contributors
    end
    github_contributors.delete_all
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

  def format_metrics(metrics)
    metrics_map = {}
    metrics.sort_by { |m| [m.week_timestamp, -m.total_commits]}.each do |metric|
      if metrics_map.key?(metric.github_id)
        metric_map = metrics_map[metric.github_id]
      else
        metric_map = {
            github_id: metric.github_id,
            user_name: metric.user_name,
            total_commits: metric.total_commits,
            week_timestamp: [],
            lines_added: [],
            lines_removed: [],
            lines_changed: []
        }
      end
      time_stamp = metric.week_timestamp.to_i * 1000
      metric_map[:lines_added] << [time_stamp, metric.lines_added]
      metric_map[:lines_removed] << [time_stamp, metric.lines_removed]
      metric_map[:lines_changed] << [time_stamp, metric.lines_changed]
      metrics_map[metric.github_id] = metric_map
    end
    return metrics_map
  end

end
