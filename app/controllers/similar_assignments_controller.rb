class SimilarAssignmentsController < ApplicationController
  include SimilarAssignmentsHelper
  include ResponseConstants
  include SimilarAssignmentsConstants
  before_action :validate_user, only: [:get, :update]
  skip_before_action :authorize, only: [:get, :update]


  # GET /similar_assignments/:id
  def get
    @assignment_id = params[:id]
    ids = Response.joins("INNER JOIN response_maps ON response_maps.id = responses.map_id WHERE visibility=2 AND reviewed_object_id = "+@assignment_id.to_s).ids
    if ids.empty?
      render json: {"success"=>false, "error"=>"Please mark atleast one review as sample"}
      return
    end
    begin
      @similar_assignments = SimilarAssignment.where(:assignment_id => @assignment_id).where.not(:is_similar_for=>@assignment_id).order("created_at DESC").pluck(:is_similar_for)
    rescue ActiveRecord::RecordNotFound => e
      render json: {"success" => false, "error" => "Resource not found"}
    else
      @res = get_asssignments_set(@similar_assignments)
      render json: {"success" => true, "values" => @res}
    end
  end

  # POST /similar_assigments/:id
  def update
    begin
      @check_lists = params[:similar].to_hash
      @assignment_id = params[:id].to_i
      checked_list = @check_lists["checked"]
      unchecked_list = @check_lists["unchecked"]
      ids = Response.joins("INNER JOIN response_maps ON response_maps.id = responses.map_id WHERE visibility=2 AND reviewed_object_id = "+@assignment_id.to_s).ids
      if ids.empty?
        render json: {"success" => false, "error" => "Please mark atleast one review as sample"}
        return
      end
      if !checked_list.nil?        
          checked_list.each do |child|
          id = SimilarAssignment.where(:is_similar_for => child.to_i, :association_intent => intent_review,
                                       :assignment_id => @assignment_id).ids
          if id.empty?
            SimilarAssignment.create({:is_similar_for => child.to_i, :association_intent => intent_review,
                                        :assignment_id => @assignment_id})
            end
        end
      end

      if !unchecked_list.nil?
        unchecked_list.each do |child|
          id = SimilarAssignment.where(:is_similar_for => child.to_i, :association_intent => intent_review,
                                       :assignment_id => @assignment_id).ids
          if !(id.empty?)
            SimilarAssignment.where({:is_similar_for => child.to_i, :association_intent => intent_review,
                                     :assignment_id => @assignment_id}).destroy_all
          end
        end
      end
    rescue
      render json: {"success" => false, "error" => "An error occurred."}
    else
      render json: {"success" => true}
    end
  end

  def validate_user
    if Role.student.id == current_user.role.id
      respond_to do |format|
          format.html {redirect_to list_student_task_index_path}
      end
    end
  end
end