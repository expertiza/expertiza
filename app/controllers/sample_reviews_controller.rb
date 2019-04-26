class SampleReviewsController < ApplicationController
  skip_before_action :authorize, only: [:update_visibility, :show, :index, :add]

  include ResponseConstants
  include SimilarAssignmentsConstants
  include SimilarAssignmentsHelper
  include SampleReviewsHelper

  #Displays review details in Question and Answer format.
  def show
    if redirect_anonymous_user?
      redirect_to '/' and return
    end
    response_id = params[:id]
    # redirect to home page if Response is not an approved sample review
    if Response.find(response_id).visibility != 2
      redirect_to '/'
      return
    end

    # get all questions and answers associated with this sample review
    q_and_a_data = Answer.joins("INNER JOIN questions ON question_id = questions.id WHERE answers.response_id=#{response_id.to_s}")

    questions_query_result = Question.find(q_and_a_data.pluck(:question_id))
    questions_map = {} # map to store question text (value) against question id (key)
    questions_query_result.each do |question|
      if !questions_map.key?(question.id)
        questions_map[question.id] = question.txt
      end
    end
    # construct @qa_table to get a list of key-value tuples, each representing question and answer
    @qa_table = []
    q_and_a_data.each do |answer|
      question_text = questions_map[answer.question_id]
      answer_text = answer.comments.strip
      if question_text.size > 0 and answer_text.size > 0
        @qa_table.push({:question=>question_text,:answer=>answer_text})
      end
    end
    # construct the heading of the page
    assignment_id = ResponseMap.find(Response.find(response_id).map_id).reviewed_object_id
    @course_assignment_name = get_course_assignment_name(assignment_id)
  end

  def add
    assignment_id = params[:a_id];
    reviewer_user_id = params[:reviewer_id];
    reviewee_team_id = params[:reviewee_id];
    current_assignment_id = params[:curr_assignment_id];

    response_map_ids = Response.where(visibility: 2).pluck(:map_id)
    response_maps_with_distinct_reviewer_id =
        ResponseMap.where('reviewed_object_id IN (?) AND id IN (?) ',assignment_id,response_map_ids).pluck(:reviewer_id)


    sample_review = ResponseMap.where('reviewed_object_id IN (?) AND reviewer_id IN (?) AND reviewee_id IN (?)', assignment_id, response_maps_with_distinct_reviewer_id,reviewee_team_id).pluck(:id)


    review = Samplereviewmap.create(response_map_id: sample_review[0], assignment_id: current_assignment_id )
    review.save
    render json: {"success" => true}
  end


  #Displays list of sample reviews.
  def index
    if redirect_anonymous_user?
      redirect_to '/' and return
    end
    @assignment_id = params[:id].to_i
    # page_number variable is used for limit and offset in query
    page_number = params[:page].to_i
    if page_number.nil?
      page_number = 0
    end
    @page_size = 8
    # get all response map ids that are marked as sample
    response_map_ids = Samplereviewmap.where(:assignment_id => @assignment_id).pluck(:response_map_id)

    @response_ids = []
    # get all Responses that are samples from this colletion of assignments
    response_map_ids.each do |id|
      _offset = page_number * @page_size
      #ids = Response.joins("INNER JOIN response_maps ON response_maps.id = responses.map_id WHERE status = 2 and " +
      #                        " ORDER BY responses.created_at LIMIT "+@page_size.to_s+" OFFSET "+_offset.to_s ).ids

      ids = Response.where(" map_id = " + id.to_s + " and visibility = 2" ).ids

      @response_ids += ids
    end
    @links = generate_links(@response_ids)
    # respond with HTML if initial request, or JSON if pagination request
    if page_number == 0
      @course_assignment_name = get_course_assignment_name(@assignment_id)
    else
      render json: {"success" => true, "sampleReviews" => @links}
    end
  end

  #Updats the visibility status in Response table.
  def update_visibility
    begin
      visibility = params[:visibility] #response object consists of visibility in string format
      # validate the request
      if(visibility.nil?)
        raise StandardError.new("Missing parameter 'visibility'")
      end
      visibility = visibility.to_i
      if not (_private.._selected).include? visibility
        raise StandardError.new("Invalid value for parameter 'visibility'")
      end
      @@response_id = params[:id]
      response_map_id = Response.find(@@response_id).map_id
      response_map = ResponseMap.find(response_map_id)
      assignment_id = response_map.reviewed_object_id
      is_admin = [Role.administrator.id,Role.superadministrator.id].include? current_user.role.id
      if is_admin
        Response.update(@@response_id.to_i, :visibility => visibility)
       # update_similar_assignment(assignment_id, visibility)
        render json:{"success" => true}
        return
      end
      course_id = Assignment.find(assignment_id).course_id
      instructor_id = Course.find(course_id).instructor_id
      ta_ids = []
      if current_user.role.id == Role.ta.id
        ta_ids = TaMapping.where(course_id).ids # do this query only if current user is ta
      elsif current_user.role.id == Role.student.id
        # find if this student id is the same as the response reviewer id
        # and that visiblity is 0 or 1 and nothing else.
        # if anything fails, return failure
        if visibility > _public
          render json:{"success" => false, "error"=>"Not allowed"}
          return
        end
        reviewer_user_id = AssignmentParticipant.find(response_map.reviewer_id).user_id
        if reviewer_user_id != current_user.id
          render json:{"success" => false,"error" => "Unathorized"}
          return
        end
      elsif not ([instructor_id] + ta_ids).include? current_user.id
        render json:{"success" => false,"error" => "Unathorized"}
        return
      end
      Response.update(@@response_id.to_i, :visibility => visibility)
     # update_similar_assignment(assignment_id, visibility)
    rescue StandardError => e
      render json:{"success" => false,"error" => e.message}
    else
      render json:{"success" => true}
    end
  end

  private
  #Updates SimilarAssignment table.
  def update_similar_assignment(assignment_id, visibility)
    if visibility == _selected
      ids = SimilarAssignment.where(:is_similar_for => assignment_id, :association_intent => intent_review,
                                    :assignment_id => assignment_id).ids
      if ids.empty?
        SimilarAssignment.create({:is_similar_for => assignment_id, :association_intent => intent_review,
                                  :assignment_id => assignment_id})
      end
    end
    if visibility == _selected or visibility == _private
      response_map_ids = ResponseMap.where(:reviewed_object_id => assignment_id).ids
      response_ids = Response.where(:map_id => response_map_ids, :visibility => _selected)
      if response_ids.empty?
        SimilarAssignment.where(:assignment_id => assignment_id).destroy_all
      end
    end
  end

  #Used to generate links for the sample reviews.
  def generate_links(response_ids)
    links = []
    response_ids.each do |id|
      links.append('/sample_reviews/show/' + id.to_s)
    end
    links
  end

  #Returns concatenation of Course name and Assignment name, given assignment id
  def get_course_assignment_name(assignment_id)
    assignment_name = Assignment.find(assignment_id).name
    course_id = Assignment.find(assignment_id).course_id
    course_name = Course.find(course_id).name
    if course_name.size > 0 && assignment_name.size > 0
      course_assignment_name = course_name + " - " + assignment_name
    elsif course_name.size > 0
      course_assignment_name = course_name
    elsif assignment_name.size > 0
      course_assignment_name = assignment_name
    else
      course_assignment_name = "assignment"
    end
    return course_assignment_name
  end
end