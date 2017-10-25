class SubmissionRecordsController < ApplicationController
  before_action :set_submission_record, only: [:show, :edit, :update, :destroy]
  GIT_HUB_REGEX = /https?:\/\/([w]{3}\.)?github.com\/([A-Z0-9_\-]+)\/([A-Z0-9_\-]+)[\S]*/i
  def action_allowed?
    # currently we only have a index method which shows all the submission records given a team_id
    assignment_team = AssignmentTeam.find(params[:team_id])
    assignment = Assignment.find(assignment_team.parent_id)
    return true if ['Super-Administrator', 'Administrator'].include? current_role_name
    return true if assignment.instructor_id == current_user.id
    return true if TaMapping.exists?(ta_id: current_user.id, course_id: assignment.course_id) && (TaMapping.where(course_id: assignment.course_id).include?TaMapping.where(ta_id: current_user.id, course_id: assignment.course_id).first)
    return true if assignment.course_id && Course.find(assignment.course_id).instructor_id == current_user.id
    false
  end

  # Show submission records.
  # expects to get team_id from params
  def index
    latest_record_counter = 0
    @submission_records = SubmissionRecord.where(team_id: params[:team_id])
    @submission_records.reverse.each do |record|
      matches = GIT_HUB_REGEX.match(record.content)
       if(matches.nil?)
       else
         if record.operation == "Submit Hyperlink"
            if latest_record_counter == 0
              GitDatum.update_git_data(record.id)
              @authors = GitDatum.where("submission_record_id = ?", record.id).map(&:author).uniq{|x| x}
              @record_id = record.id
            else
              @git_data = GitDatum.where("submission_record_id = ?", record.id)
              @git_data.each{|data| data.destroy}
            end
         end
         latest_record_counter = latest_record_counter + 1;
       end
    end
  end
end
