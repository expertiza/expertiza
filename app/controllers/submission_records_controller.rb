class SubmissionRecordsController < ApplicationController
  before_action :set_submission_record, only: [:show, :edit, :update, :destroy]
  
  def action_allowed?
    if params[:action] == 'edit' || params[:action] == 'update'
      assignment = Assignment.find(params[:id])
      return true if ['Super-Administrator', 'Administrator'].include? current_role_name
      return true if assignment.instructor_id == current_user.id
      return true if TaMapping.exists?(ta_id: current_user.id, course_id: assignment.course_id) && (TaMapping.where(course_id: assignment.course_id).include?TaMapping.where(ta_id: current_user.id, course_id: assignment.course_id).first)
      return true if assignment.course_id && Course.find(assignment.course_id).instructor_id == current_user.id
      return false
    else
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
    end
  end

  # GET /submission_records
  def index
    @submission_records = SubmissionRecord.all
  end

  # GET /submission_records/1
  def show
  end

  # GET /submission_records/new
  def new
    @submission_record = SubmissionRecord.new
  end

  # GET /submission_records/1/edit
  def edit
  end

  # POST /submission_records
  def create
    @submission_record = SubmissionRecord.new(submission_record_params)

    if @submission_record.save
      redirect_to @submission_record, notice: 'Submission record was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /submission_records/1
  def update
    if @submission_record.update(submission_record_params)
      redirect_to @submission_record, notice: 'Submission record was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /submission_records/1
  def destroy
    @submission_record.destroy
    redirect_to submission_records_url, notice: 'Submission record was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission_record
      @submission_record = SubmissionRecord.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def submission_record_params
      params[:submission_record]
    end
end
