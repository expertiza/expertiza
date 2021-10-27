require 'json'
require 'uri'
require 'net/http'
require 'openssl'
require 'base64'

class ReputationWebServiceController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_ta_privileges?
  end

  # calculating the grade for each review
  def calculate_peer_grade(response)
    answers = Answer.where(response_id: response.id)
    max_question_score = answers.first.question.questionnaire.max_question_score rescue 1
    temp_sum = 0
    weight_sum = 0
    # filtering the valid answers
    valid_answer = answers.select {|a| a.question.type == 'Criterion' and !a.answer.nil? }
    # skipping this if its empty!
    return nil if valid_answer.empty?
    valid_answer.each do |answer|
      temp_sum += answer.answer * answer.question.weight
      weight_sum += answer.question.weight
    end
    peer_review_grade = 100.0 * temp_sum / (weight_sum * max_question_score)
    peer_review_grade.round(4)
  end

  # returning the grades for all valid reviews
  def fetch_peer_reviews(assignment_id, round_num, has_topic, another_assignment_id = 0)
    raw_data_array = []
    assignment_ids = []
    assignment_ids << assignment_id
    assignment_ids << another_assignment_id unless another_assignment_id.zero?
    ReviewResponseMap.where('reviewed_object_id in (?) and calibrate_to = ?', assignment_ids, false).each do |response_map|
      reviewer = response_map.reviewer.user
      team = AssignmentTeam.find(response_map.reviewee_id)
      topic_condition = ((has_topic and SignedUpTeam.where(team_id: team.id).first.is_waitlisted == false) or !has_topic)
      # filtering the responses that are round_num
      last_valid_response = response_map.response.select {|r| r.round == round_num }.sort.last
      valid_response = [last_valid_response] unless last_valid_response.nil?
      next unless topic_condition == true and !valid_response.nil? and !valid_response.empty?
      valid_response.each do |response|
        # calculating grades for each review
        peer_review_grade = calculate_peer_grade(response)
        # skipping if the grade is nil
        if !peer_review_grade.nil?
          raw_data_array << [reviewer.id, team.id, peer_review_grade.round(4)]
        end
      end
    end
    raw_data_array
  end

  # special db query, return quiz scores
  def fetch_quiz_scores(assignment_id, another_assignment_id = 0)
    raw_data_array = []
    assignment_ids = []
    assignment_ids << assignment_id
    assignment_ids << another_assignment_id unless another_assignment_id.zero?
    teams = AssignmentTeam.where('parent_id in (?)', assignment_ids)
    team_ids = []
    teams.each {|team| team_ids << team.id }
    quiz_questionnnaires = QuizQuestionnaire.where('instructor_id in (?)', team_ids)
    quiz_questionnnaire_ids = []
    quiz_questionnnaires.each {|questionnaire| quiz_questionnnaire_ids << questionnaire.id }
    # Getting quiz score for each team
    QuizResponseMap.where('reviewed_object_id in (?)', quiz_questionnnaire_ids).each do |response_map|
      quiz_score = response_map.quiz_score
      participant = Participant.find(response_map.reviewer_id)
      raw_data_array << [participant.user_id, response_map.reviewee_id, quiz_score]
    end
    raw_data_array # returning quiz scores of all the teams
  end

  # generating json for the fetched scores/reviews
  def generate_json(assignment_id, another_assignment_id = 0, round_num = 2, type = 'peer review grades')
    assignment = Assignment.find_by(id: assignment_id)
    has_topic = !SignUpTopic.where(assignment_id: assignment_id).empty?

    if type == 'peer review grades'
      @results = fetch_peer_reviews(assignment.id, round_num, has_topic, another_assignment_id)
    elsif type == 'quiz scores'
      @results = fetch_quiz_scores(assignment.id, another_assignment_id)
    end
    request_body = {}
    @results.each_with_index do |record, _index|
      request_body['submission' + record[1].to_s] = {} unless request_body.key?('submission' + record[1].to_s)
      request_body['submission' + record[1].to_s]['stu' + record[0].to_s] = record[2]
    end
    # sort the 2-dimension hash
    request_body.each {|k, v| request_body[k] = v.sort.to_h }
    request_body.sort.to_h
  end

  def client
    @max_assignment_id = Assignment.last.id
    @result
  end

  # encrypting the peer review grade data using AES
  def encrypt_review_data(body)
    aes_encrypted_request_data = aes_encrypt(body)
    body = aes_encrypted_request_data[0]
    # RSA asymmetric algorithm encrypts keys of AES
    encrypted_key = rsa_public_key1(aes_encrypted_request_data[1])
    encrypted_vi = rsa_public_key1(aes_encrypted_request_data[2])
    # fixed length 350
    body.prepend('", "data":"')
    body.prepend(encrypted_vi)
    body.prepend(encrypted_key)
    # request body should be in JSON format.
    body.prepend('{"keys":"')
    body << '"}'
    body.gsub!(/\n/, '\\n')
    body
  end

  # decrypting the peer review grade data using AES
  def decrypt_review_data(body)
    body = JSON.parse(body)
    # RSA asymmetric algorithm decrypts keys of AES
    key = rsa_private_key2(body["keys"][0, 350])
    vi = rsa_private_key2(body["keys"][350, 350])
    # AES symmetric algorithm decrypts data
    aes_encrypted_response_data = body["data"]
    aes_decrypt(aes_encrypted_response_data, key, vi)
  end

  def update_reputation(body)
    JSON.parse(body.to_s).each do |alg, list|
      next unless alg == "Hamer" || alg == "Lauw"
      list.each do |id, rep|
        # skipping lenient Id's
        Participant.find_by(user_id: id).update(alg.to_sym => rep) unless /leniency/ =~ id.to_s
      end
    end
    redirect_to action: 'client'
  end

  # sending the post request to calculate reputation scores of review grades.
  def send_post_request
    # https://www.socialtext.net/open/very_simple_rest_in_ruby_part_3_post_to_create_a_new_workspace
    req = Net::HTTP::Post.new('/reputation/calculations/reputation_algorithms', initheader = {'Content-Type' => 'application/json', 'charset' => 'utf-8'})
    curr_assignment_id = (params[:assignment_id].empty? ? '754' : params[:assignment_id])
    req.body = generate_json(curr_assignment_id, params[:another_assignment_id].to_i, params[:round_num].to_i, 'peer review grades').to_json
    req.body[0] = '' # remove the first '{'
    @assignment = params[:assignment_id]
    @round_num = params[:round_num]
    @algorithm = params[:algorithm]
    @another_assignment = params[:another_assignment_id]
    if params[:checkbox][:expert_grade] == 'Add expert grades'
      @additional_info = 'add expert grades'
      case params[:assignment_id]
      when '754' # expert grades of Wiki contribution (754)
        req.body.prepend("\"expert_grades\": {\"submission25030\":95,\"submission25031\":92,\"submission25033\":88,\"submission25034\":98,\"submission25035\":100,\"submission25037\":95,\"submission25038\":95,\"submission25039\":93,\"submission25040\":96,\"submission25041\":90,\"submission25042\":100,\"submission25046\":95,\"submission25049\":90,\"submission25050\":88,\"submission25053\":91,\"submission25054\":96,\"submission25055\":94,\"submission25059\":96,\"submission25071\":85,\"submission25082\":100,\"submission25086\":95,\"submission25097\":90,\"submission25098\":85,\"submission25102\":97,\"submission25103\":94,\"submission25105\":98,\"submission25114\":95,\"submission25115\":94},")
      end
    elsif params[:checkbox][:hamer] == 'Add initial Hamer reputation values'
      @additional_info = 'add initial hamer reputation values'
    elsif params[:checkbox][:lauw] == 'Add initial Lauw reputation values'
      @additional_info = 'add initial lauw reputation values'
    elsif params[:checkbox][:quiz] == 'Add quiz scores'
      @additional_info = 'add quiz scores'
      # generating the json request body based upon the parameters.
      quiz_str = generate_json(params[:assignment_id].to_i, params[:another_assignment_id].to_i, params[:round_num].to_i, 'quiz scores').to_json
      quiz_str[0] = ''
      quiz_str.prepend('"quiz_scores":{')
      quiz_str += ','
      quiz_str = quiz_str.gsub('"N/A"', '20.0')
      req.body.prepend(quiz_str)
    else
      @additional_info = ''
    end
    # Eg.
    # "{"initial_hamer_reputation": {"stu1": 0.90, "stu2":0.88, "stu3":0.93, "stu4":0.8, "stu5":0.93, "stu8":0.93},  #optional
    # "initial_lauw_leniency": {"stu1": 1.90, "stu2":0.98, "stu3":1.12, "stu4":0.94, "stu5":1.24, "stu8":1.18},  #optional
    # "expert_grades": {"submission1": 90, "submission2":88, "submission3":93},  #optional
    # "quiz_scores" : {"submission1" : {"stu1":100, "stu3":80}, "submission2":{"stu2":40, "stu1":60}}, #optional
    # "submission1": {"stu1":91, "stu3":99},"submission2": {"stu5":92, "stu8":90},"submission3": {"stu2":91, "stu4":88}}"
    req.body.prepend("{")
    @request_body = req.body
    # Encryption
    req.body = encrypt_review_data(req.body)  # AES symmetric algorithm encrypts raw data
    # sending the post request.
    response = Net::HTTP.new('peerlogic.csc.ncsu.edu').start {|http| http.request(req) }
    # Decryption
    response.body = decrypt_review_data(response.body)
    # {response.body}"
    @response = response
    @response_body = response.body
    update_reputation(response.body)
  end

  # returns the encrypted public key
  def rsa_public_key1(data)
    # obtains the public key file from config folder
    public_key_file = 'public1.pem'
    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
    encrypted_string = Base64.encode64(public_key.public_encrypt(data))
    encrypted_string
  end

  # returns the decrypted private key
  def rsa_private_key2(cipertext)
    private_key_file = 'private2.pem'
    encrypted_string = cipertext
    # getting the password from DB
    password = KeyMapping.find_by(name:'rsa_key').value
    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file), Base64.decode64(password))
    string = private_key.private_decrypt(Base64.decode64(encrypted_string))
    string
  end

  # encrypting the request body
  def aes_encrypt(data)
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    key = cipher.random_key
    iv = cipher.random_iv
    cipertext = Base64.encode64(cipher.update(data) + cipher.final)
    [cipertext, key, iv]
  end

  # decrypting the response body
  def aes_decrypt(cipertext, key, iv)
    decipher = OpenSSL::Cipher::AES.new(256, :CBC)
    decipher.decrypt
    decipher.key = key
    decipher.iv = iv
    plain = decipher.update(Base64.decode64(cipertext)) + decipher.final
    plain
  end
end
