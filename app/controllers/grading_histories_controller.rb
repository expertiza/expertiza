class GradingHistoriesController < ApplicationController
  before_action :set_grading_history, only: [:show, :edit, :update, :destroy]

  # GET /grading_histories
  # return all grading history entries for the assignment
  # entries are returned in chronological order
  def index
    @grading_histories = GradingHistory.where(grade_receiver_id: params[:grade_receiver_id], grading_type: params[:grade_type]).reverse_order
  end

  # GET /grading_histories/1
  def show
  end

  # GET /grading_histories/new
  def new
    @grading_history = GradingHistory.new
  end

  # GET /grading_histories/1/edit
  def edit
  end

  # POST /grading_histories
  def create
    @grading_history = GradingHistory.new(grading_history_params)

    if @grading_history.save
      redirect_to @grading_history, notice: 'Grading history was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /grading_histories/1
  def update
    if @grading_history.update(grading_history_params)
      redirect_to @grading_history, notice: 'Grading history was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /grading_histories/1
  def destroy
    @grading_history.destroy
    redirect_to grading_histories_url, notice: 'Grading history was successfully destroyed.'
  end

  def action_allowed?
    # admins and superadmins are always allowed
    return true if current_user_has_admin_privileges?
    # populate assignment fields
    assignment_for_history(params[:grade_type])
    # if not admin/superadmin, check permissions
    if @assignment.instructor_id == current_user.id
      true
    elsif TaMapping.exists?(ta_id: current_user.id, course_id: @assignment.course_id) &&
      (TaMapping.where(course_id: @assignment.course_id).include? TaMapping.where(ta_id: current_user.id, course_id: @assignment.course_id).first)
      true
    elsif @assignment.course_id && Course.find(@assignment.course_id).instructor_id == current_user.id
      true
    end
  end

  # populate the assignment fields according to type
  def assignment_for_history(type)
    # for a submission, the receiver is an AssignmentTeam
    # use this AssignmentTeam to find the assignment
    if type.eql? 'Submission'
      assignment_team = AssignmentTeam.find(params[:grade_receiver_id])
      @assignment = Assignment.find(assignment_team.parent_id)
    end
    # for a review, the receiver is an AssignmentParticipant
    # use this AssignmentParticipant to find the assignment
    if type.eql? 'Review'
      participant_id = params[:participant_id]
      grade_receiver = AssignmentParticipant.find(participant_id)
      @assignment = Assignment.find(grade_receiver.parent_id)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grading_history
      @grading_history = GradingHistory.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def grading_history_params
      params.require(:grading_history).permit(:grading_type, :grade, :comment)
    end
end
