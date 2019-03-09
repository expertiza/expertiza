class CourseBadgesController < ApplicationController
  before_action :set_course_badge, only: [:show, :edit, :update, :destroy]
  include GradesHelper

  @@x_api_key =  CREDLY_CONFIG["api_key"]
  @@x_api_secret = CREDLY_CONFIG["api_secret"]

  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator'].include? current_role_name
  end

  # GET /course_badges
  def index
    @course_badges = CourseBadge.all
    @preference = BadgePreference.find_by_instructor_id(session[:user])
    @disclaimer = !@preference.nil? and @preference.preference
  end

  # GET /course_badges/1
  def show
  end

  # GET /course_badges/new
  def new
    @course_badge = CourseBadge.new
  end

  # GET /course_badges/1/edit
  def edit
  end

  def delete_badge_from_course
    @badge_id = params[:course_badge][:badge_id]
    @course_id = params[:course_badge][:course_id]

    CourseBadge.where(badge_id: @badge_id, course_id: @course_id).destroy_all

    render status: 200, json: {status: 200, message: "Course badge destroyed"}
  end

  # GET /course_badges/awarding?course_id
  def awarding
    if !params['course_id'].nil?
       @course = Course.find(params['course_id'])
    elsif !params['assignment_id'].nil?
      @assignments = Assignment.where(id: params['assignment_id'])
      @course = @assignments.first.course
    end

    if !@course.nil?
      # get avg score of each participant in different assignment in the course
      @assignments = Assignment.where(course_id: @course.id)
      @course_badges = CourseBadge.where(course_id: @course.id)
      ta_user_ids = TaMapping.where(course: @course).pluck(:id)
      @participants = CourseParticipant.where(parent_id: @course.id).where.not(user_id: ta_user_ids)

      # initialize nested hash
      # From: http://www.ruby-forum.com/topic/111524, Author: Daniel Martin
      @score = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }
      @award = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }

      # load awarded badges to this participant
      @participants.each do |p|
        @course_badges.each do |course_badge|
          awarded = AwardedBadge.where(participant: p, badge: course_badge.badge)
          @award[p.id][course_badge.badge.id] = true if awarded.count > 0
        end
      end

      @assignments.each do |assignment|
        # load all scores from different assignments
        questions = retrieve_questions assignment.questionnaires, assignment.id
        assignment_participants = AssignmentParticipant.where(assignment: assignment).where.not(user_id: ta_user_ids)
        assignment_participants.each_with_index do |participant, i|
          break if i>5 # debugging purpose
          course_participant = CourseParticipant.where(user_id: participant.user.id, parent_id: params['course_id']).first
          next if course_participant.nil?

          scores = participant.scores(questions)
          @score[course_participant.id][assignment.id]['avg_score'] = scores[:review][:scores][:avg].nil? ? 'N/A' : scores[:review][:scores][:avg].round(1)
          @score[course_participant.id][assignment.id]['avg_reviewing'] = scores[:feedback][:scores][:avg].nil? ? 'N/A' : scores[:feedback][:scores][:avg].round(1)
          @score[course_participant.id][assignment.id]['course_participant'] = course_participant.id
          @score[course_participant.id][assignment.id]['assignment_participant'] = participant.id


        end
      end
    else
      @error = true
      flash[:error] = "Couldn't find courses with id " + params['course_id']
      return
    end
  end

  def awarding_submit
    tokens = UserCredlyToken.where(user_id: current_user.id).last

    # extract unchecked checkboxes
    deleted_cb = params
                     .select { |key, value| key.to_s.starts_with?("deleted_award_") }
                     .map{|k, v| k.split("_") << v}

    # if there are any hiden field for checkboxes that were unchecked, we delete the award in the DB, then ask credly to revoke the badges
    # badges revocation in credly only works for premium membership, but I'll leave the code there
    deleted_cb.each do |del_cb|
      # del_cb[2] contains the id of the assignment participant
      participant = Participant.find(del_cb[2])
      # del_cb[3] contains the id of the badge
      badge = Badge.find(del_cb[3])
      awarded = AwardedBadge.where(:participant => participant, :badge => badge).first
      if !awarded.nil?
        awarded.destroy
      end

      # retract badges in credly
      form_data = {member_badge_id: awarded.external_id,
                   reason: 1,
                   :multipart => true}
      headers = {"X-Api-Key": @@x_api_key,
                 "X-Api-Secret": @@x_api_secret}
      url = CREDLY_CONFIG["credly_api_url"] + "member_badges?access_token=" + tokens.access_token
      begin
        response = RestClient::Request.execute(:method => 'delete', :url => url, :payload => form_data, :headers => headers)
      rescue StandardError => e
        flash[:error] = e.message
      end

    end unless deleted_cb.nil?

    # the id of each check box contains the user_id (index 1) and badge_id (index 2) seperated by underscore
    checkboxes = params
                     .select { |key, value| key.to_s.starts_with?("award_") }
                     .map{|k, v| k.split("_") << v}
    checkboxes.each do |cb|
      if !cb[3].eql? "awarded"
        participant = Participant.find(cb[1])
        user = participant.user
        badge = Badge.find(cb[2])

        # for now include all links from all assignment,
        # TODO: create a UI for instructor to choose which links to be included
        txt = ""
        participant.assignment_participants.each do |p|
          next if p.nil?
          submissions = p.team.hyperlinks unless p.team.nil?
          txt += "Submissions in the assignment \"" + p.assignment.name + "\":"
          submissions.each do |link|
            txt += "\n\t" + link
          end unless submissions.nil?
          txt += "\n\n"
        end

        evidence = Base64.encode64(txt)

        form_data = {email: user.email,
                     first_name: user.fullname.split(",")[1],
                     last_name: user.fullname.split(",")[0],
                     badge_id: badge.external_badge_id,
                     distributed_at:  Time.now.strftime('%Y-%m-%d %X'),
                     evidence_file: evidence,
                     :multipart => true}
        headers = {"X-Api-Key": @@x_api_key,
                   "X-Api-Secret": @@x_api_secret}
        url = CREDLY_CONFIG["credly_api_url"] + "member_badges?access_token=" + tokens.access_token
        begin
          response = RestClient.post(url, form_data, headers=headers)

          ext_id = JSON.parse(response.to_str)['data']['ids'][0]

          # store awarded badges in local db
          awarded = AwardedBadge.find_or_create_by(:participant => participant, :badge => badge, :external_id => ext_id)
        rescue StandardError => e
          flash[:error] = e.message
          break
        end
      end

    end
    flash[:success] = "badge awards have been sucessfully updated"
    redirect_to :back
  end

  def create
    @badge_id = params[:course_badge][:badge_id]
    @course_id = params[:course_badge][:course_id]

    CourseBadge.create(badge_id: @badge_id, course_id: @course_id)

    render status: 200, json: {status: 200, message: "Course badge created"}
  end

  # PATCH/PUT /course_badges/1
  def update
    if @course_badge.update(course_badge_params)
      redirect_to @course_badge, notice: 'Course badge was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /course_badges/1
  def destroy
    @course_badge.destroy
    redirect_to course_badges_url, notice: 'Course badge was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_badge
      @course_badge = CourseBadge.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def course_badge_params
      params.require(:course_badge).permit(:badge_id, :course_id, :award_mechanism, :manual_award_criteria)
    end
end
