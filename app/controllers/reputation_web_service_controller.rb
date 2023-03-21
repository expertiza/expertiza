require 'json'
require 'uri'
require 'net/http'
require 'openssl'
require 'base64'

# Expertiza allows student work to be peer-reviewed, since peers can provide
# more feedback than the instructor can.
# However, if we want to assure that all students receive competent feedback,
# or even use peer-assigned grades,
# we need a way to judge which peer reviewers are most credible. The solution
# is the reputation system.
# Reputation systems have been deployed as web services, peer-review
# researchers will be able to use them to calculate scores on assignments,
# both past and present (past data can be used to tune the algorithms).
#
# This file is the controller to calculate the reputation scores.
# A 'reputation' measures how close a reviewer's scores are to other reviewers'
# scores.
# This controller implements the calculation of reputation scores.
class ReputationWebServiceController < ApplicationController
  include AuthorizationHelper

  # Method: action_allowed
  # This method checks if the currently authenticated user has the authorization
  # to perform certain actions
  # Params
  #
  # Returns
  #   true if the user has privileges to perform the action else returns false
  def action_allowed?
    current_user_has_ta_privileges?
  end

  # Method: get_max_question_score
  # This method receives a set of answers and gets the maximum question score
  # Params
  #   answers: set of answers
  # Returns
  #   if no error returns max_question_score of first question else 1
  def get_max_question_score(answers)
    begin
      answers.first.question.questionnaire.max_question_score
    rescue StandardError
      1
    end
  end

  # Method: get_valid_answers_for_response
  # This method receives response and filters the valid answers list of the
  # response ID
  # Params
  #   response
  # Returns
  #   set of valid answers (returns nil if empty)
  def get_valid_answers_for_response(response)
    answers = Answer.where(response_id: response.id)
    valid_answer = answers.select { |answer| (answer.question.type == 'Criterion') && !answer.answer.nil? }
    valid_answer.empty? ? nil : valid_answer
  end

  # Method: calculate_peer_review_grade
  # This method calculates a cumulative review grade with respect to the set of valid answers
  # Params
  #   valid_answer: valid answer to get weight of the answer's question
  #   max_question_score: used to calculate maximum score for peer review grade
  # Returns
  #   peer_review_grade
  def calculate_peer_review_grade(valid_answer, max_question_score)
    weighted_score_sum = valid_answer.map { |answer| answer.answer * answer.question.weight }.inject(:+)
    question_weight_sum = valid_answer.sum { |answer| answer.question.weight }
    peer_review_grade = 100.0 * weighted_score_sum / (question_weight_sum * max_question_score)
    peer_review_grade.round(4)
  end

  # Method: get_peer_reviews_for_responses
  # This method calculates the peer review grade for each valid response
  # Params
  #   reviewer_id: used to create respective element in the peer_review_grades_list
  #   team_id: used to create respective element in the peer_review_grades_list
  #   valid_response: to get the valid answer for each valid response
  # Returns
  #   peer_review_grades_list
  def get_peer_reviews_for_responses(reviewer_id, team_id, valid_response)
    peer_review_grades_list = []
    valid_response.each do |response|
      valid_answer = get_valid_answers_for_response(response)
      next if valid_answer.nil?

      review_grade = calculate_peer_review_grade(valid_answer, get_max_question_score(valid_answer))
      peer_review_grades_list << [reviewer_id, team_id, review_grade]
    end
    peer_review_grades_list
  end

  # Method: get_peer_reviews
  # This method retrieves all the reviews for the submissions
  # Params
  #   assignment_id_list: used to retrieve response map
  #   round_num: used to retrieve round_num for the valid response
  #   has_topic: to get the topic condition
  # Returns
  #   raw_data_array: which corresponds to the return of
  #     get_peer_reviews_for_responses method and appended to the raw_data_array
  def get_peer_reviews(assignment_id_list, round_num, has_topic)
    raw_data_array = []
    ReviewResponseMap.where('reviewed_object_id in (?) and calibrate_to = ?', assignment_id_list, false).each do |response_map|
      reviewer = response_map.reviewer.user
      team = AssignmentTeam.find(response_map.reviewee_id)
      topic_condition = ((has_topic && (SignedUpTeam.where(team_id: team.id).first.is_waitlisted == false)) || !has_topic)
      last_valid_response = response_map.response.select { |r| r.round == round_num }.max
      valid_response = [last_valid_response] unless last_valid_response.nil?
      if (topic_condition == true) && !valid_response.nil? && !valid_response.empty?
        raw_data_array += get_peer_reviews_for_responses(reviewer.id, team.id, valid_response)
      end
    end
    raw_data_array
  end

  # Method: get_ids_list
  # This method maps each object to the corresponding object's ID
  # Params
  #   tables: any table
  # Returns
  #   id in the tables
  def get_ids_list(tables)
    tables.map(&:id)
  end

  # Method: get_scores
  # This method gets the quiz score of each participant for respective reviewee
  # Params
  #   team_ids: list of team IDs
  # Returns
  #   raw_data_array: which is a list of participant, reviewee and the participant's quiz score
  def get_scores(team_ids)
    quiz_questionnnaires = QuizQuestionnaire.where('instructor_id in (?)', team_ids)
    quiz_questionnnaire_ids = get_ids_list(quiz_questionnnaires)
    raw_data_array = []
    QuizResponseMap.where('reviewed_object_id in (?)', quiz_questionnnaire_ids).each do |response_map|
      quiz_score = response_map.quiz_score
      participant = Participant.find(response_map.reviewer_id)
      raw_data_array << [participant.user_id, response_map.reviewee_id, quiz_score]
    end
    raw_data_array
  end

  # Method: get_quiz_score
  # This method gets the quiz score of assignments
  # Params
  #   assignment_id_list: list of assignment IDs
  # Returns
  #   raw_data_array: returned by get_scores method, which is a list of participant,
  #     reviewee and the participant's quiz score
  def get_quiz_score(assignment_id_list)
    teams = AssignmentTeam.where('parent_id in (?)', assignment_id_list)
    team_ids = get_ids_list(teams)
    get_scores(team_ids)
  end

  # Method: generate_json_body
  # This method generates json body for the peer reviews and quiz scores
  # Params
  #   results: list of grades with corresponding team/participant ID,
  #     reviewee ID and their score
  # Returns
  #   request_body: returns the formatted body after sorting the hash
  def generate_json_body(results)
    request_body = {}
    results.each_with_index do |record, _index|
      request_body['submission' + record[1].to_s] = {} unless request_body.key?('submission' + record[1].to_s)
      request_body['submission' + record[1].to_s]['stu' + record[0].to_s] = record[2]
    end
    # sort the 2-dimension hash
    request_body.each { |k, v| request_body[k] = v.sort.to_h }
    request_body.sort.to_h
    request_body
  end

  # Method: generate_json_for_peer_reviews
  # This method retrieves all the peer reviews associated with
  # the assignment id list by calling the get_peer_reviews method.
  # It then formats the peer-review list in JSON.
  # Params
  #   assignment_id_list: list of assignment ids to get quiz scores for
  #   round_num: round number of the review
  # Returns
  #   request_body: request body populated with the formatted peer review data.
  def generate_json_for_peer_reviews(assignment_id_list, round_num = 2)
    has_topic = !SignUpTopic.where(assignment_id: assignment_id_list[0]).empty?

    peer_reviews_list = get_peer_reviews(assignment_id_list, round_num, has_topic)
    request_body = generate_json_body(peer_reviews_list)
    request_body
  end

  # Method: generate_json_for_quiz_scores
  # This method accepts a list of assignment ids as an argument.
  # It then calls the get_quiz_score method on the list to get
  # maps of teams and scores for the given assignments.
  # The map is then formatted into JSON.
  # Params
  #   assignment_id_list: list of assignment ids to get quiz scores for
  # Returns
  #   request_body: request body populated with quiz scores
  def generate_json_for_quiz_scores(assignment_id_list)
    participant_reviewee_map = get_quiz_score(assignment_id_list)
    request_body = generate_json_body(participant_reviewee_map)
    request_body
  end

  # Method: client
  # This method is called when the url reputation_web_service/client
  # is hit using GET method.
  # This renders the client.html.erb
  # It also populates the instance variables to be used in the views
  # Params
  #
  # Returns
  #   nil
  def client
    @max_assignment_id = Assignment.last.id
    @assignment = Assignment.find(flash[:assignment_id]) rescue nil
    @another_assignment = Assignment.find(flash[:another_assignment_id]) rescue nil
  end

  # Method: update_participants_reputation
  # This method accepts the response body in the JSON format.
  # It then parses the JSON and updates the reputation scores of the
  # participants in the list.
  # If the alg variable is not  Hamer/ Lauv, the updation step is skipped.
  # Params
  #   reputation_response: The response from the reputation web service
  # Returns
  #   nil
  def update_participants_reputation(reputation_response)
    JSON.parse(reputation_response.body.to_s).each do |reputation_algorithm, user_resputation_list|
      next unless %w[Hamer Lauw].include?(reputation_algorithm)

      user_resputation_list.each do |user_id, reputation|
        Participant.find_by(user_id: user_id).update(reputation_algorithm.to_sym => reputation) unless /leniency/ =~ user_id.to_s
      end
    end
  end

  # Method: process_response_body
  # This method gets the control after receiving a response from the server.
  # It receives the response body as an argument
  # It updates the instance variables related to the response.
  # It then calls the update_participants_reputation to update the reputation
  # scores received in the response body.
  # Params
  #   reputation_response: The response from the reputation web service
  # Returns
  #   nil
  def process_response_body(reputation_response)
    flash[:response] = reputation_response
    flash[:response_body] = reputation_response.body
    update_participants_reputation(reputation_response)
  end

  # Method: add_expert_grades
  # It prepends the request body with the expert grades pertaining
  # to the default wiki contribution case of 754.
  # It receives the request body as an argument and prepends it
  # Params
  #   body: The request body to add the expert grades to
  # Returns
  #   body prepended with the expert grades
  def add_expert_grades(body)
    flash[:additional_info] = 'add expert grades'
    case params[:assignment_id]
    when '754' # expert grades of Wiki contribution (754)
      body.prepend('"expert_grades": {"submission25030":95,"submission25031":92,"submission25033":88,"submission25034":98,"submission25035":100,"submission25037":95,"submission25038":95,"submission25039":93,"submission25040":96,"submission25041":90,"submission25042":100,"submission25046":95,"submission25049":90,"submission25050":88,"submission25053":91,"submission25054":96,"submission25055":94,"submission25059":96,"submission25071":85,"submission25082":100,"submission25086":95,"submission25097":90,"submission25098":85,"submission25102":97,"submission25103":94,"submission25105":98,"submission25114":95,"submission25115":94},')
    end
  end

  # Method: add_quiz_scores
  # It gets the assignment id list and generates the json on quiz scores of
  # those assignments.
  # Finally processes quiz string is prepended to the request body, received
  # as an argument, and returns the body to prepare_request_body.
  # Params
  #   body: The request body to add the expert grades to
  # Returns
  #   body prepended with the expert grades
  def add_quiz_scores(body)
    flash[:additional_info] = 'add quiz scores'
    assignment_id_list_quiz = get_assignment_id_list(params[:assignment_id].to_i, params[:another_assignment_id].to_i)
    quiz_str =  generate_json_for_quiz_scores(assignment_id_list_quiz).to_json
    quiz_str[0] = '' # remove first {
    quiz_str.prepend('"quiz_scores":{') # add quiz_scores tag
    quiz_str += ','
    quiz_str = quiz_str.gsub('"N/A"', '20.0') # replace N/A values with 20
    body.prepend(quiz_str)
  end

  # Method: add_lauw_reputation_values
  # This method sets the instance variable @additional_info.
  # This method is called by the prepare_request_body method
  # when params receive instruction through the corresponding view's checkbox.
  # THIS METHOD IS NOT IMPLETEMENTED
  # Params
  #
  # Returns
  #   nil
  def add_hamer_reputation_values
    flash[:additional_info] = 'add initial hamer reputation values'
  end

  # Method: add_lauw_reputation_values
  # This method sets the instance variable @additional_info.
  # This method is called by the prepare_request_body method
  # when params receive instruction through the corresponding view's checkbox.
  # THIS METHOD IS NOT IMPLETEMENTED
  # Params
  #
  # Returns
  #   nil
  def add_lauw_reputation_values
    flash[:additional_info] = 'add initial lauw reputation values'
  end

  # Method: get_assignment_id_list
  # This method on receipt of individual assignment IDs returns a list with all
  # the assignment IDs appended into a data structure
  # This function accepts 2 arguments, with the second argument being optional,
  # and returns the list assignment_id_list
  # If the second argument is 0, it is not appended to the list.
  # Params
  #   assignment_id_one: first assignment id (required)
  #   assignment_id_two: second assignment id (optional)
  # Returns
  #   assignment_id_list: list containing two assignment ids
  def get_assignment_id_list(assignment_id_one, assignment_id_two = 0)
    assignment_id_list = []
    assignment_id_list << assignment_id_one
    assignment_id_list << assignment_id_two unless assignment_id_two.zero?
    assignment_id_list
  end

  # Method: add_flash_messages
  # This method sets the flash messages to pass on to the next request i.e
  # the request redirected to the client
  # Params
  #   post_req: This contains the entire post_req that needs to be sent to the reputation
  #     webservice
  # Returns
  #   nil
  def add_flash_messages(post_req)
    flash[:assignment_id] = params[:assignment_id]
    flash[:round_num] = params[:round_num]
    flash[:algorithm] = params[:algorithm]
    flash[:another_assignment_id] = params[:another_assignment_id]
    flash[:request_body] = post_req.body
  end

  # Method: add_additional_info_details
  # This method sets the additional info details based on the options
  # selected in the additional information section. We populate the request
  # based on the selections
  # Params
  #   post_req: This contains the entire post_req that needs to be sent to the reputation
  #     webservice
  # Returns
  #   nil
  def add_additional_info_details(post_req)
    if params[:checkbox][:expert_grade] == 'Add expert grades'
      add_expert_grades(post_req.body)
    elsif params[:checkbox][:hamer] == 'Add initial Hamer reputation values'
      add_hamer_reputation_values
    elsif params[:checkbox][:lauw] == 'Add initial Lauw reputation values'
      add_lauw_reputation_values
    elsif params[:checkbox][:quiz] == 'Add quiz scores'
      add_quiz_scores(post_req.body)
    else
      flash[:additional_info] = ''
    end
  end

  # Method: prepare_request_body
  # This method is responsible for preparing the request body in a proper format
  # to send to the server. It populates the assignment scores and peer review
  # scores. It also populates the flash messages to send to the next request
  # It finally sends the prepared request body back to the send_post_request
  # method.
  # Params
  #
  # Returns
  #   nil
  def prepare_request_body
    reputation_web_service_path = URI.parse(WEBSERVICE_CONFIG['reputation_web_service_url']).path
    post_req = Net::HTTP::Post.new(reputation_web_service_path, { 'Content-Type' => 'application/json', 'charset' => 'utf-8' })
    curr_assignment_id = (params[:assignment_id].empty? ? '754' : params[:assignment_id])
    assignment_id_list_peers = get_assignment_id_list(curr_assignment_id, params[:another_assignment_id].to_i)

    post_req.body = generate_json_for_peer_reviews(assignment_id_list_peers, params[:round_num].to_i).to_json

    post_req.body[0] = '' # remove the first '{'
    add_additional_info_details post_req
    post_req.body.prepend('{')
    add_flash_messages post_req
    post_req
  end

  # Method: send_post_request
  # This method calls the prepare_request_body function to get a prepared
  # request body in proper format to send to the server.
  # It populates the assignment scores and peer review
  # scores. It also populates the flash messages to send to the next request
  # We redirect to the client url to display the results.
  # Params
  #
  # Returns
  #   nil
  def send_post_request
    post_req = prepare_request_body
    reputation_web_service_hostname = URI.parse(WEBSERVICE_CONFIG['reputation_web_service_url']).host
    reputation_response = Net::HTTP.new(reputation_web_service_hostname).start { |http| http.request(post_req) }
    if %w[400 500].include?(reputation_response.code)
      flash[:error] = 'Post Request Failed'
    else
      process_response_body(reputation_response)
    end
    redirect_to action: 'client'
  end
end
