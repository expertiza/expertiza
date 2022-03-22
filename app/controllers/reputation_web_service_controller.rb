require 'json'
require 'uri'
require 'net/http'
require 'openssl'
require 'base64'

# Expertiza allows student work to be peer-reviewed, since peers can provide more feedback than the instructor can.
# However, if we want to assure that all students receive competent feedback, or even use peer-assigned grades,
# we need a way to judge which peer reviewers are most credible. The solution is the reputation system.
# Reputation systems have been deployed as web services, peer-review researchers will be able to use them to calculate scores on assignments,
# both past and present (past data can be used to tune the algorithms).
#
# This file is the controller to calculate the reputation scores.
# A 'reputation' measures how close a reviewer's scores are to other reviewers' scores.
# This controller implements the calculation of reputation scores.
class ReputationWebServiceController < ApplicationController
  include AuthorizationHelper

  # action_allowed? function checks if the currently authenticated user has the authorization to perform certain actions.
  # This function returns true if the user has privileges to perform the action. Otherwise, it returns false.
  def action_allowed?
    current_user_has_ta_privileges?
  end

  # get_max_question_score receives a set of answers as an argument and gets the question associated with the answers.
  # It then returns the maximum score of the question from the relevant questionnaire record.
  # In case of standard error, this method returns 1
  def get_max_question_score(answers)
    begin
      answers.first.question.questionnaire.max_question_score
    rescue StandardError
      1
    end
  end

  # get_valid_answers_for_response method retrieves the answer list using the id of the received response.
  # It filters out the answers list to select non-empty answers of criterion question type as valid_answer.
  # return valid_answers if it is not an empty list.
  def get_valid_answers_for_response(response)
    answers = Answer.where(response_id: response.id)
    valid_answer = answers.select { |a| (a.question.type == 'Criterion') && !a.answer.nil? }
    valid_answer.empty? ? nil : valid_answer
  end

  # calculate_peer_review_grade calculates a cumulative review grade with respect to the set of valid answers.
  # This function takes in arguments of valid_answer and the maximum score of the question.
  # peer_review_grade is calculated as a percentage of valid answers' cumulative weight in the answer's cumulative weight of the maximum score.
  def calculate_peer_review_grade(valid_answer, max_question_score)
    temp_sum = 0
    weight_sum = 0
    valid_answer.each do |answer|
      temp_sum += answer.answer * answer.question.weight
      weight_sum += answer.question.weight
    end
    peer_review_grade = 100.0 * temp_sum / (weight_sum * max_question_score)
    peer_review_grade.round(4)
  end

  # get_peer_reviews_for_responses calculates the peer review grade for each valid response.
  # It gets a peer review grade for each valid answer associated with each valid response.
  # Calculated grades along with reviewer ID and team ID are appended to a list and returned.
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

  # get_peer_reviews, for a given assignment list ids, retrieves all the reviews for the submitted works.
  # For each review, the reviewer, the team being reviewed, and the validly submitted works are queried for.
  # These results are sent to get_peer_reviews_for_responses for getting the review grade for that particular review.
  # reviewer_id, team_id, review_grade are appended to the raw_data_array list and returned.
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

  # get_ids_list accepts a list of objects and maps each object to the corresponding object id attribute.
  # This method returns the altered list to the caller function.
  def get_ids_list(tables)
    tables.map(&:id)
  end

  # get_scores method accepts team IDs as an argument.
  # It then finds all the quiz questionnaires associated with all the teams in the list.
  # For each questionnaire, it retrieves the reviewer id, reviewee id, and score.
  # This data is appended to the raw data list and returned.
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

  # get_quiz_score takes a list of assignment IDs as arguments.
  # Queries the AssignmentTeam to find the teams participating in the assignment.
  # Stores the IDs of the teams in team_ids.
  # It calls get_scores on team_ids to get the scores of all the participating teams.
  def get_quiz_score(assignment_id_list)
    teams = AssignmentTeam.where('parent_id in (?)', assignment_id_list)
    team_ids = get_ids_list(teams)
    get_scores(team_ids)
  end

  # generate_json_body is a helper method.
  # It accepts unformatted string data and formats it into JSON.
  # It returns the formatted body after sorting the hash.
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

  # generate_json_for_peer_reviews takes assignment_id_list and round number as arguments.
  # This method retrieves all the peer reviews associated with the assignment id list by calling the get_peer_reviews method.
  # It then formats the peer-review list in JSON by calling generate_json_body method.
  # it returns the formatted peer review data.
  def generate_json_for_peer_reviews(assignment_id_list, round_num = 2)
    has_topic = !SignUpTopic.where(assignment_id: assignment_id_list[0]).empty?

    peer_reviews_list = get_peer_reviews(assignment_id_list, round_num, has_topic)
    request_body = generate_json_body(peer_reviews_list)
    request_body
  end

  # generate_json_for_quiz_scores accepts a list of assignment ids as an argument.
  # It then calls the get_quiz_score method on the list to get maps of teams and scores for the given assignments.
  # The map is then formatted into JSON by calling generate_json_body and returns it.
  def generate_json_for_quiz_scores(assignment_id_list)
    participant_reviewee_map = get_quiz_score(assignment_id_list)
    request_body = generate_json_body(participant_reviewee_map)
    request_body
  end

  # This method returns the id of the last assignment.
  def client
    @max_assignment_id = Assignment.last.id
    @assignment = Assignment.find(flash[:assignment_id]) rescue nil
    @another_assignment = Assignment.find(flash[:another_assignment_id]) rescue nil
  end

  # encrypt_request_body is used by the method prepare_request_body.
  # This method takes in the plain request body data, encrypts the data using AES symmetric algorithm.
  # It then uses RSA asymetric encryption to encrypt the AES keys.
  # Then the encrypted data is prepended with the encrypted keys and sent back to the prepare_request_body method.
  def encrypt_request_body(plain_data)
    # AES symmetric algorithm encrypts raw data
    aes_encrypted_request_data = aes_encrypt(plain_data)
    encrypted_data = aes_encrypted_request_data[0]

    # RSA asymmetric algorithm encrypts keys of AES
    encrypted_key = rsa_public_key1(aes_encrypted_request_data[1])
    encrypted_vi = rsa_public_key1(aes_encrypted_request_data[2])

    encrypted_data.prepend('", "data":"')
    encrypted_data.prepend(encrypted_vi)
    encrypted_data.prepend(encrypted_key)

    encrypted_data
  end

  # format_into_json accepts the unformatted string data pertaining to the request body.
  # Unoformatted string data is converted into JSON format in this method.
  # JSON formatted request body is returned to the prepare_request_body method.
  def format_into_json(unformatted_data)
    unformatted_data.prepend('{"keys":')
    unformatted_data << '}'
    formatted_data = unformatted_data.gsub!(/\n/, '\\n')
    formatted_data = formatted_data.nil? ? unformatted_data : formatted_data
    formatted_data
  end

  # decrypt_response decrypts the encrypted response body.
  # It accepts the encrypted body in JSON format.
  # RSA decryption is first done on the keys.
  # Decrypted keys are then used to perform AES decryption on the data.
  # Decrypted data is sent back to the process_response_body method.
  def decrypt_response(encrypted_data)
    encrypted_data = JSON.parse(encrypted_data)
    key = rsa_private_key2(encrypted_data['keys'][0, 350])
    vi = rsa_private_key2(encrypted_data['keys'][350, 350])
    # AES symmetric algorithm decrypts data
    aes_encrypted_response_data = encrypted_data['data']
    decrypted_data = aes_decrypt(aes_encrypted_response_data, key, vi)
    decrypted_data
  end

  # update_participants_reputation accepts the decrypted response body in the JSON format.
  # It then parses the JSON and updates the reputation scores of the participants in the list.
  # If the alg variable is not  Hamer/ Lauv, the updation step is skipped.
  def update_participants_reputation(response)
    JSON.parse(response.body.to_s).each do |alg, list|
      next unless %w[Hamer Lauw].include?(alg)

      list.each do |id, rep|
        Participant.find_by(user_id: id).update(alg.to_sym => rep) unless /leniency/ =~ id.to_s
      end
    end
  end

  # process_response_body gets the control after receiving a response from the server.
  # It receives the response body as an argument
  # It calls the decrypt_response to decrypt the data back into plain request body data.
  # It updates the instance variables related to the response.
  # It then calls the update_participants_reputation to update the reputation scores received in the response body.
  # Finally the control redirects to the client.

  def process_response_body(response)
    # Decryption
    # response.body = decrypt_response(response.body)

    flash[:response] = response
    flash[:response_body] = response.body

    update_participants_reputation(response)
  end

  # add_expert_grades sets the @additional_info to 'add expert grades'
  # It prepends the request body with the expert grades pertaining to the default wiki contribution case of 754
  # It receives the request body as an argument, prepends it, and returns the body to the caller function (prepare_request_body)
  def add_expert_grades(body)
    flash[:additional_info] = 'add expert grades'
    case params[:assignment_id]
    when '754' # expert grades of Wiki contribution (754)
      body.prepend('"expert_grades": {"submission25030":95,"submission25031":92,"submission25033":88,"submission25034":98,"submission25035":100,"submission25037":95,"submission25038":95,"submission25039":93,"submission25040":96,"submission25041":90,"submission25042":100,"submission25046":95,"submission25049":90,"submission25050":88,"submission25053":91,"submission25054":96,"submission25055":94,"submission25059":96,"submission25071":85,"submission25082":100,"submission25086":95,"submission25097":90,"submission25098":85,"submission25102":97,"submission25103":94,"submission25105":98,"submission25114":95,"submission25115":94},')
    end
  end

  # add_quiz_scores is a helper function of prepare_request_body.
  # It sets the instance variable @additional_info.
  # It gets the assignment id list and generates the json on quiz scores of those assignments.
  # Finally processes quiz string is prepended to the request body, received as an argument, and returns the body to prepare_request_body.
  def add_quiz_scores(body)
    flash[:additional_info] = 'add quiz scores'
    assignment_id_list_quiz = get_assignment_id_list(params[:assignment_id].to_i, params[:another_assignment_id].to_i)
    quiz_str =  generate_json_for_quiz_scores(assignment_id_list_quiz).to_json
    quiz_str[0] = ''
    quiz_str.prepend('"quiz_scores":{')
    quiz_str += ','
    quiz_str = quiz_str.gsub('"N/A"', '20.0')
    body.prepend(quiz_str)
  end

  # add_hamer_reputation_values sets the instance variable @additional_info.
  # This method is called by the prepare_request_body method when params receive instruction through the corresponding view's checkbox.
  def add_hamer_reputation_values
    flash[:additional_info] = 'add initial hamer reputation values'
  end

  # add_lauw_reputation_values sets the instance variable @additional_info.
  # This method is called by the prepare_request_body method when params receive instruction through the corresponding view's checkbox.
  def add_lauw_reputation_values
    flash[:additional_info] = 'add initial lauw reputation values'
  end

  # get_assignment_id_list on receipt of individual assignment IDs returns a list with all the assignment IDs appended into a data structure
  # This function accepts 2 arguments, with the second argument being optional, and returns the list assignment_id_list
  # If the second argument is 0, it is not appended to the list.
  def get_assignment_id_list(assignment_id_one, assignment_id_two)
    assignment_id_list = []
    assignment_id_list << assignment_id_one
    assignment_id_list << assignment_id_two unless assignment_id_two.zero?
    assignment_id_list
  end

  # prepare_request_body method is responsible for preparing the request body in a proper format to send to the server.
  # It gets the raw request body and populates the class variables based on the received parameters.
  # It further calls the methods: encrypt_request_body and format_into_json to get the request body into the correct format.
  # It finally sends the prepared request body back to the send_post_request method.
  def prepare_request_body
    reputation_web_service_path = URI.parse(WEBSERVICE_CONFIG['reputation_web_service_url']).path
    req = Net::HTTP::Post.new(reputation_web_service_path, { 'Content-Type' => 'application/json', 'charset' => 'utf-8' })
    curr_assignment_id = (params[:assignment_id].empty? ? '754' : params[:assignment_id])
    assignment_id_list_peers = get_assignment_id_list(curr_assignment_id, params[:another_assignment_id].to_i)

    req.body = generate_json_for_peer_reviews(assignment_id_list_peers, params[:round_num].to_i).to_json

    req.body[0] = '' # remove the first '{'
    flash[:assignment_id] = params[:assignment_id]
    flash[:round_num] = params[:round_num]
    flash[:algorithm] = params[:algorithm]
    flash[:another_assignment_id] = params[:another_assignment_id]

    if params[:checkbox][:expert_grade] == 'Add expert grades'
      add_expert_grades(req.body)
    elsif params[:checkbox][:hamer] == 'Add initial Hamer reputation values'
      add_hamer_reputation_values
    elsif params[:checkbox][:lauw] == 'Add initial Lauw reputation values'
      add_lauw_reputation_values
    elsif params[:checkbox][:quiz] == 'Add quiz scores'
      add_quiz_scores(req.body)
    else
      flash[:additional_info] = ''
    end

    req.body.prepend('{')
    flash[:request_body] = req.body
    # Encrypting the request body data
    # req.body = encrypt_request_body(req.body)

    # request body should be in JSON format.
    # req.body = format_into_json(req.body)
    req
  end

  # send_post_request function calls the prepare_request_body function to get a prepared request body in proper format.
  # It then sends the prepared request to the server.
  # Finally, it forwards the received response to the process_response_body function.
  # The core of this function deals with sending a request to calculate the review scores, receiving and forwarding the response to the processing function.
  def send_post_request
    req = prepare_request_body
    reputation_web_service_hostname = URI.parse(WEBSERVICE_CONFIG['reputation_web_service_url']).host
    response = Net::HTTP.new(reputation_web_service_hostname).start { |http| http.request(req) }
    if %w[400 500].include?(response.code)
      flash[:error] = 'Post Request Failed'
    else
      process_response_body(response)
    end
    redirect_to action: 'client'
  end

  def rsa_public_key1(data)
    public_key_file = 'public1.pem'
    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
    encrypted_string = Base64.encode64(public_key.public_encrypt(data))

    encrypted_string
  end

  def rsa_private_key2(ciphertext)
    private_key_file = 'private2.pem'
    password = "ZXhwZXJ0aXph\n"
    encrypted_string = ciphertext
    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file), Base64.decode64(password))
    string = private_key.private_decrypt(Base64.decode64(encrypted_string))

    string
  end

  def aes_encrypt(data)
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    key = cipher.random_key
    iv = cipher.random_iv
    ciphertext = Base64.encode64(cipher.update(data) + cipher.final)
    [ciphertext, key, iv]
  end

  def aes_decrypt(ciphertext, key, iv)
    decipher = OpenSSL::Cipher::AES.new(256, :CBC)
    decipher.decrypt
    decipher.key = key
    decipher.iv = iv
    plain = decipher.update(Base64.decode64(ciphertext)) + decipher.final
    plain
  end
end
