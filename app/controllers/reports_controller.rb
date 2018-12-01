class ReportsController < ApplicationController
  autocomplete :user, :name
  require 'gchart'
  helper :submitted_content
  include ReportFormatterHelper

  # start_self_review is a method that is invoked by a student user so it should be allowed accordingly
  def action_allowed?
    case params[:action]
    when 'add_dynamic_reviewer',
          'show_available_submissions',
          'assign_reviewer_dynamically',
          'assign_metareviewer_dynamically',
          'assign_quiz_dynamically',
          'start_self_review'
      true
    else ['Instructor', 'Teaching Assistant', 'Administrator'].include? current_role_name
    end
  end

  def response_report
    # ACS Removed the if condition(and corresponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @type = params.key?(:report) ? params[:report][:type] : 'ReviewResponseMap'
    # From the ReportFormatterHelper module
    render_report(@type, params, session)
    @user_pastebins = UserPastebin.get_current_user_pastebin current_user
  end
end
