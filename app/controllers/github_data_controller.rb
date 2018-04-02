class GithubDataController < ApplicationController
  class QueryError < StandardError; end

  def action_allowed?
    @submission_record = SubmissionRecord.find(params[:id])
    assignment_team = AssignmentTeam.find(@submission_record.team_id)
    assignment = Assignment.find(assignment_team.parent_id)
    return true if ['Super-Administrator', 'Administrator'].include? current_role_name
    return true if assignment.instructor_id == current_user.id
    return true if TaMapping.exists?(ta_id: current_user.id, course_id: assignment.course_id) && (TaMapping.where(course_id: assignment.course_id).include? TaMapping.where(ta_id: current_user.id, course_id: assignment.course_id).first)
    return true if assignment.course_id && Course.find(assignment.course_id).instructor_id == current_user.id
  end

  def show
    @commits = GithubDatum.where(submission_record_id: @submission_record.id)
    @commits = GithubDatum.new.retrieve_commit_data(@submission_record) if @commits.length == 0
    #New hash with default value 0
    @commits_by_user = Hash.new(0)
    #New nested hash with nested values defaulting to 0
    @changes_by_date = Hash.new { |h,k| h[k] = Hash.new(0) }
    @commits.each do |commit|
      @commits_by_user[commit.committer] += 1
      @changes_by_date[commit.committed_date.strftime('%Y-%m-%d')][:commits] += 1
      @changes_by_date[commit.committed_date.strftime('%Y-%m-%d')][:additions] += commit.additions
      @changes_by_date[commit.committed_date.strftime('%Y-%m-%d')][:deletions] += commit.deletions
      @changes_by_date[commit.committed_date.strftime('%Y-%m-%d')][:changed_files] += commit.changed_files
    end unless @commits.nil?
  end

end
