class TeamNominationsController < ApplicationController
  before_action :fetch_params, only: [:list_badges, :nominate]
  before_action :fetch_course_badges, only: [:list_badges]
  before_action :fetch_reviewer, only: [:list_badges, :nominate]

  @@x_api_key =  CREDLY_CONFIG["api_key"]
  @@x_api_secret = CREDLY_CONFIG["api_secret"]

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
      nominated = TeamNomination.where("team_id = ? and badge_id = ? and nominator_id = ? and status != ?", @team_id, course_badge.badge, @reviewer, "disapproved")
      @is_checked[@team_id][course_badge.badge.id] = true if nominated.count > 0
      @disable_checkbox[@team_id][course_badge.badge.id] = nominated.first.status == "approved" unless nominated.first.nil?
    end
  end

  # Allows peers to nominate teams
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
        nominated = TeamNomination.where(team: team, badge: badge, nominator_id: @reviewer).first
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
      TeamNomination.where("status != ?", "disapproved").find_or_create_by(:team => team, :badge => badge, nominator_id: @reviewer) do |nomination|
        nomination.status = "pending_approval"
        nomination.nominator_id = @reviewer.id unless @reviewer.nil?
        nomination.assignment_id = @assignment.id
      end
    end
    flash[:success] = "Nominations have been successfully updated"
    redirect_to :back
  end

  #Lists down all the team nominations for a paticular course.
  def list_badge_nominations
    @course_id = params[:course_id]
    @course_name = Course.find(@course_id).name
    @nominations = TeamNomination.get_nominations @course_id
  end

  # To approve/disapprove nominations.
  def approve
    tokens = UserCredlyToken.where(user_id: current_user.id).last
    course_id = params[:course_id]
    list_to_approve = params
                      .select {|key, value| key.to_s.starts_with?("nomination_") }
                      .map {|k, v| k.split("_") }

    list_to_approve.each do |entry|
      nomination = TeamNomination.find(entry[2])
      team = nomination.team
      badge = nomination.badge
      assignment = nomination.assignment

      if entry[1] == "approve"
        participants = TeamsUser.where(team_id: team.id)
        course = assignment.course

        txt = ""
        submissions = team.submitted_hyperlinks.split(' ')
        txt += "Submissions in the assignment \"" + assignment.name + "\":"
        unless submissions.nil?
          submissions.each do |link|
            next if link == "---" || link == '-'

            txt += "\n\t" + link
          end
        end
        txt += "\n\n"
        evidence = Base64.encode64(txt)

        participants.each do |participant|
          participant_id_for_course = Participant.where(user_id: participant.user_id, parent_id: course.id).first
          is_awarded = AwardedBadge.where(badge_id: badge.id, participant_id: participant_id_for_course.id)
          next if is_awarded.count > 0

          user = User.find(participant.user_id)
          form_data = {email: user.email,
                       first_name: user.fullname.split(",")[1],
                       last_name: user.fullname.split(",")[0],
                       badge_id: badge.external_badge_id,
                       distributed_at: Time.now.strftime('%Y-%m-%d %X'),
                       evidence_file: evidence,
                       :multipart => true}
          headers = {"X-Api-Key": @@x_api_key,
                     "X-Api-Secret": @@x_api_secret}
          url = CREDLY_CONFIG["credly_api_url"] + "member_badges?access_token=" + tokens.access_token
          begin
            response = RestClient.post(url, form_data, headers = headers)
            ext_id = JSON.parse(response.to_str)['data']['ids'][0]

            # store awarded badges in local db
            awarded = AwardedBadge.find_or_create_by(badge_id: badge.id, participant_id: participant_id_for_course.id, external_id: ext_id)
          rescue StandardError => e
            flash[:error] = e.message
            break
          end
        end
        TeamNomination.where(team: team, badge: badge, assignment: assignment).update_all(status: "approved")
      else
        TeamNomination.where(team: team, badge: badge, assignment: assignment).update_all(status: "disapproved")
      end
    end
    flash[:success] = "Nominations have been successfully updated"
    redirect_to :back
  end
end