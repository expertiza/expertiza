class TeamNominationsController < ApplicationController
  before_action :fetch_params
  before_action :fetch_course_badges, only: [:list_badges]
  before_action :fetch_reviewer

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include? current_role_name
  end

  def fetch_params
    @assignment = Assignment.find(params[:id])
    @model = params[:model]
    @team_id = params[:team_id]
  end

  def fetch_course_badges
    course = @assignment.course
    @course_badges = CourseBadge.where(course_id: course.id)
  end

  def fetch_reviewer
    @reviewer = Participant.where(user: current_user.id, parent_id: @assignment.id).first
  end

  def list_badges
    @is_checked = Hash.new {|h, k| h[k] = Hash.new(&h.default_proc) }
    @disable_checkbox = Hash.new {|h, k| h[k] = Hash.new(&h.default_proc) }
    @course_badges.each do |course_badge|
      nominated = TeamNomination.where(team: @team_id, badge: course_badge.badge)
      @is_checked[@team_id][course_badge.badge.id] = true if nominated.count > 0
      @disable_checkbox[@team_id][course_badge.badge.id] = nominated.first.status == "approved" unless nominated.first.nil?
    end
  end

  def nominate
    # extract unchecked checkboxes
    deleted_cb = params
                 .select {|key, value| key.to_s.starts_with?("deleted_nomination_") }
                 .map {|k, v| k.split("_") << v }

    # if there is any hidden field for checkboxes that were unchecked, we delete the nomination in the DB.
    unless deleted_cb.nil?
      deleted_cb.each do |del_cb|
        # del_cb[2] contains the id of the assignment participant
        team = AssignmentTeam.find(del_cb[2])
        # del_cb[3] contains the id of the badge
        badge = Badge.find(del_cb[3])
        nominated = TeamNomination.where(team: team, badge: badge).first
        nominated.destroy unless nominated.nil?
      end
    end

    # the id of each check box contains the user_id (index 1) and badge_id (index 2) seperated by underscore
    checkboxes = params
                 .select {|key, value| key.to_s.starts_with?("nomination_") }
                 .map {|k, v| k.split("_") << v }

    checkboxes.each do |cb|
      next if cb[3].eql? "nominated"

      team = AssignmentTeam.find(cb[1])
      # user = participant.user
      badge = Badge.find(cb[2])
      # store nominations in local db
      TeamNomination.find_or_create_by(:team => team, :badge => badge) do |nomination|
        nomination.status = "pending_approval"
        nomination.nominator_id = @reviewer.id unless @reviewer.nil?
      end
    end
    flash[:success] = "Nominations have been successfully updated"
    redirect_to :back
  end
end
