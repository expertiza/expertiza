class CourseBadgesController < ApplicationController
  before_action :set_course_badge, only: [:show, :edit, :update, :destroy]
  include GradesHelper

  # GET /course_badges
  def index
    @course_badges = CourseBadge.all
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

  # GET /course_badges/awarding?course_id
  def awarding

    if !params['course_id'].nil?
       course = Course.find(params['course_id'])
    elsif !params['assignment_id'].nil?
      @assignments = Assignment.where(id: params['assignment_id'])
      course = @assignments.first.course
    end

    if !course.nil?
      # get avg score of each participant in different assignment in the course
      @assignments = Assignment.where(course_id: course.id)
      @course_badges = CourseBadge.where(course_id: course.id)
      @participants = CourseParticipant.where(parent_id: course.id)

      # initialize nested hash
      # From: http://www.ruby-forum.com/topic/111524, Author: Daniel Martin
      @score = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }
      @award = Hash.new{ |h,k| h[k]=Hash.new(&h.default_proc) }
      @assignments.each do |assignment|
        questions = retrieve_questions assignment.questionnaires, assignment.id
        assignment_participants = AssignmentParticipant.where(assignment: assignment)
        assignment_participants.each_with_index do |participant, i|
          course_participant = CourseParticipant.where(user_id: participant.user.id, parent_id: params['course_id']).first
          next if course_participant.nil?
          scores = participant.scores(questions)
          @score[course_participant.id][assignment.id]['avg_score'] = scores[:review][:scores][:avg].nil? ? 'N/A' : scores[:review][:scores][:avg].round(1)
          @score[course_participant.id][assignment.id]['avg_reviewing'] = scores[:feedback][:scores][:avg].nil? ? 'N/A' : scores[:feedback][:scores][:avg].round(1)
          @score[course_participant.id][assignment.id]['assignment_participant'] = participant.id
          break if i>5 # debugging purpose
        end
      end
    else
      @error = true
      flash[:error] = "Couldn't find courses with id " + params['course_id']
      return
    end
  end

  # POST /course_badges
  def create
    @course_badge = CourseBadge.new(course_badge_params)

    if @course_badge.save
      redirect_to @course_badge, notice: 'Course badge was successfully created.'
    else
      render :new
    end
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
