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

  # normal db query, return peer review grades
  # query="SELECT U.id, RM.reviewee_id as submission_id, "+
  #     "sum(A.answer * Q.weight) / sum(QN.max_question_score * Q.weight) * 100 as total_score "+
  #   # new way to calculate the grades of coding artifacts
  #   #"100 - SUM((QN.max_question_score-A.answer) * Q.weight) AS total_score "+
  #   "from answers A  "+
  #   "inner join questions Q on A.question_id = Q.id "+
  #   "inner join questionnaires QN on Q.questionnaire_id = QN.id "+
  #   "inner join responses R on A.response_id = R.id "+
  #   "inner join response_maps RM on R.map_id = RM.id "+
  #   "inner join participants P on P.id = RM.reviewer_id "+
  #   "inner join users U on U.id = P.user_id "+
  #   "inner join teams T on T.id = RM.reviewee_id "
  #   query += "inner join signed_up_teams SU_team on SU_team.team_id = T.id " if has_topic == true
  #   query += "where RM.type='ReviewResponseMap' "+
  #   "and RM.reviewed_object_id = "+  assignment_id.to_s + " " +
  #   "and A.answer is not null "+
  #   "and Q.type ='Criterion' "+
  #   #If one assignment is varying rubric by round (724, 733, 736) or 2-round peer review with (735),
  #   #the round field in response records corresponding to ReviewResponseMap will be 1 or 2, will not be null.
  #   "and R.round = 2 "
  #   query+="and SU_team.is_waitlisted = 0 " if has_topic == true
  #   query+="group by RM.id "+
  #   "order by RM.reviewee_id"
  #
  #  result = ActiveRecord::Base.connection.select_all(query)git status
  # db query to return review responses
  def get_review_responses(assignment_id, another_assignment_id = 0)
    assignment_ids = []
    assignment_ids << assignment_id
    assignment_ids << another_assignment_id unless another_assignment_id.zero?
    ReviewResponseMap.where('reviewed_object_id in (?) and calibrate_to = ?', assignment_ids, false)
  end

  def calculate_peer_review_grades(has_topic, review_responses, round_num)
    raw_data_array = []
    review_responses.each do |response_map|
      reviewer = response_map.reviewer.user
      team = AssignmentTeam.find(response_map.reviewee_id)
      topic_condition = ((has_topic and SignedUpTeam.where(team_id: team.id).first.is_waitlisted == false) or !has_topic)
      last_valid_response = response_map.response.select {|r| r.round == round_num }.sort.last
      valid_response = [last_valid_response] unless last_valid_response.nil?
      next unless topic_condition == true and !valid_response.nil? and !valid_response.empty?
      valid_response.each do |response|
        answers = Answer.where(response_id: response.id)
        max_question_score = answers.first.question.questionnaire.max_question_score rescue 1
        temp_sum = 0
        weight_sum = 0
        valid_answer = answers.select {|a| a.question.type == 'Criterion' and !a.answer.nil? }
        # calculate weighted sum for valid answers
        next if valid_answer.empty?
        valid_answer.each do |answer|
          temp_sum += answer.answer * answer.question.weight
          weight_sum += answer.question.weight
        end
        peer_review_grade = 100.0 * temp_sum / (weight_sum * max_question_score)
        raw_data_array << [reviewer.id, team.id, peer_review_grade.round(4)]
      end
    end
    raw_data_array
  end

  # special db query, return quiz scores
  def calculate_quiz_scores(assignment_id, another_assignment_id = 0)
    raw_data_array = []
    assignment_ids = []
    assignment_ids << assignment_id
    assignment_ids << another_assignment_id unless another_assignment_id.zero?
    teams = AssignmentTeam.where('parent_id in (?)', assignment_ids)
    team_ids = []
    teams.each {|team| team_ids << team.id }
    quiz_questionnaires = QuizQuestionnaire.where('instructor_id in (?)', team_ids)
    quiz_questionnaire_ids = []
    quiz_questionnaires.each {|questionnaire| quiz_questionnaire_ids << questionnaire.id }
    QuizResponseMap.where('reviewed_object_id in (?)', quiz_questionnaire_ids).each do |response_map|
      quiz_score = response_map.quiz_score
      participant = Participant.find(response_map.reviewer_id)
      raw_data_array << [participant.user_id, response_map.reviewee_id, quiz_score]
    end
    raw_data_array
  end

  def generate_json(assignment_id, another_assignment_id = 0, round_num = 2, type = 'peer review grades')
    assignment = Assignment.find_by(id: assignment_id)
    has_topic = !SignUpTopic.where(assignment_id: assignment_id).empty?

    if type == 'peer review grades'
      @responses = get_review_responses(assignment.id, another_assignment_id)
      @results = calculate_peer_review_grades(has_topic,@responses, round_num)
    elsif type == 'quiz scores'
      @results = calculate_quiz_score(assignment.id, another_assignment_id)
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

  def set_request_body(request_body)
    @request_body = request_body
  end

  def get_request_body
    @request_body
  end

  def set_response_body(response_body)
    @response_body = response_body
  end

  def get_response_body
    @response_body
  end

  def set_last_assignment_id
    @max_assignment_id = Assignment.last.id
  end

  def get_last_assignment_id
    @max_assignment_id
  end

  def set_assignment(assignment_id)
    @assignment = Assignment.find(assignment_id) rescue nil
  end

  def get_assignment
    @assignment
  end

  def set_another_assignment(another_assignment_id)
    @another_assignment = Assignment.find(another_assignment_id) rescue nil
  end

  def get_another_assignment
    @another_assignment
  end

  def set_round_num(round_num)
    @round_num = round_num
  end

  def get_round_num
    @round_num
  end

  def set_algorithm(algorithm)
    @algorithm = algorithm
  end

  def get_algorithm
    @algorithm
  end

  def set_additional_info(additional_info)
    @additional_info = additional_info
  end

  def get_additional_info
    @additional_info
  end

  def set_response(response)
    @response = response
  end

  def get_response
    @response
  end

  # abhishek 10/10 8 pm
  def send_post_request
    # https://www.socialtext.net/open/very_simple_rest_in_ruby_part_3_post_to_create_a_new_workspace
    req = Net::HTTP::Post.new('/reputation/calculations/reputation_algorithms', initheader = {'Content-Type' => 'application/json', 'charset' => 'utf-8'})
    curr_assignment_id = (params[:assignment_id].empty? ? '724' : params[:assignment_id])
    req.body = json_generator(curr_assignment_id, params[:another_assignment_id].to_i, params[:round_num].to_i, 'peer review grades').to_json
    req.body[0] = '' # remove the first '{'

    set_assignment_id(params[:assignment_id])
    set_round_num(params[:round_num])
    set_algorithm(params[:algorithm])
    set_another_assignment_id(params[:another_assignment_id])

    if params[:checkbox][:expert_grade] == 'Add expert grades'
      set_additional_info(@@additional_info = 'add expert grades')
      case params[:assignment_id]

      when '735' # expert grades of program 1 (735)
        req.body.prepend("\"expert_grades\": {\"submission24083\":96.084,\"submission24085\":88.811,\"submission24086\":100,\"submission24087\":100,\"submission24088\":92.657,\"submission24091\":96.783,\"submission24092\":90.21,\"submission24093\":100,\"submission24097\":90.909,\"submission24098\":98.601,\"submission24101\":99.301,\"submission24278\":98.601,\"submission24279\":72.727,\"submission24281\":54.476,\"submission24289\":94.406,\"submission24291\":99.301,\"submission24293\":93.706,\"submission24296\":98.601,\"submission24302\":83.217,\"submission24303\":91.329,\"submission24305\":100,\"submission24307\":100,\"submission24308\":100,\"submission24311\":95.804,\"submission24313\":91.049,\"submission24314\":100,\"submission24315\":97.483,\"submission24316\":91.608,\"submission24317\":98.182,\"submission24320\":90.21,\"submission24321\":90.21,\"submission24322\":98.601},")
      when '754' # expert grades of Wiki contribution (754)
        req.body.prepend("\"expert_grades\": {\"submission25030\":95,\"submission25031\":92,\"submission25033\":88,\"submission25034\":98,\"submission25035\":100,\"submission25037\":95,\"submission25038\":95,\"submission25039\":93,\"submission25040\":96,\"submission25041\":90,\"submission25042\":100,\"submission25046\":95,\"submission25049\":90,\"submission25050\":88,\"submission25053\":91,\"submission25054\":96,\"submission25055\":94,\"submission25059\":96,\"submission25071\":85,\"submission25082\":100,\"submission25086\":95,\"submission25097\":90,\"submission25098\":85,\"submission25102\":97,\"submission25103\":94,\"submission25105\":98,\"submission25114\":95,\"submission25115\":94},")
      when '756' # expert grades of Wikipedia contribution (756)
        req.body.prepend("\"expert_grades\": {\"submission25107\":76.6667,\"submission25109\":83.3333},")

      end
    elsif params[:checkbox][:hamer] == 'Add initial Hamer reputation values'
      set_additional_info('add initial hamer reputation values')
    elsif params[:checkbox][:lauw] == 'Add initial Lauw reputation values'
      set_additional_info('add initial lauw reputation values')
    elsif params[:checkbox][:quiz] == 'Add quiz scores'
      set_additional_info('add quiz scores')
      quiz_str = json_generator(params[:assignment_id].to_i, params[:another_assignment_id].to_i, params[:round_num].to_i, 'quiz scores').to_json
      quiz_str[0] = ''
      quiz_str.prepend('"quiz_scores":{')
      quiz_str += ','
      quiz_str = quiz_str.gsub('"N/A"', '20.0')
      req.body.prepend(quiz_str)
    else
      set_additional_info('')
    end

    # Eg.
    # "{"initial_hamer_reputation": {"stu1": 0.90, "stu2":0.88, "stu3":0.93, "stu4":0.8, "stu5":0.93, "stu8":0.93},  #optional
    # "initial_lauw_leniency": {"stu1": 1.90, "stu2":0.98, "stu3":1.12, "stu4":0.94, "stu5":1.24, "stu8":1.18},  #optional
    # "expert_grades": {"submission1": 90, "submission2":88, "submission3":93},  #optional
    # "quiz_scores" : {"submission1" : {"stu1":100, "stu3":80}, "submission2":{"stu2":40, "stu1":60}}, #optional
    # "submission1": {"stu1":91, "stu3":99},"submission2": {"stu5":92, "stu8":90},"submission3": {"stu2":91, "stu4":88}}"
    req.body.prepend("{")
    set_request_body(req.body)




 # Encrypting the request being sent over the internet
    encrypted_request = encrypt_request(req)

    # Encrypted response of the request sent in previous step
    response = Net::HTTP.new('peerlogic.csc.ncsu.edu').start {|http| http.request(encrypted_request) }

    # Decrypting the response
    response.body = JSON.parse(response.body)
    decrypted_response_body= decrypt_response(response.body)

    set_response(response)
    set_response_body(decrypted_response_body)

    JSON.parse(response.body.to_s).each do |alg, list|
      next unless alg == "Hamer" || alg == "Lauw"
      list.each do |id, rep|
        Participant.find_by(user_id: id).update(alg.to_sym => rep) unless /leniency/ =~ id.to_s
      end
    end
    redirect_to action: 'set_last_assignment_id'
  end


    # RSA asymmetric algorithm decrypts keys of AES
    # Decryption
  def decrypt_request(response)

      key = rsa_private_key2(response["keys"][0, 350])
      vi = rsa_private_key2(response["keys"][350, 350])
      # AES symmetric algorithm decrypts data
      aes_encrypted_response_data = response["data"]
      decrypted_response = aes_decrypt(aes_encrypted_response_data, key, vi)
      decrypt_response
  end

    # Encryption
    # AES symmetric algorithm encrypts raw data
  def encrypt_request(request)
      aes_encrypted_request_data = aes_encrypt(request.body)
      request = aes_encrypted_request_data[0]
      # RSA asymmetric algorithm encrypts keys of AES
      encrypted_key = rsa_public_key1(aes_encrypted_request_data[1])
      encrypted_vi = rsa_public_key1(aes_encrypted_request_data[2])
      # fixed length 350
      request.body.prepend('", "data":"')
      request.body.prepend(encrypted_vi)
      request.body.prepend(encrypted_key)
      # request body should be in JSON format.
      request.body.prepend('{"keys":"')
      request.body<< '"}'
      request.body.gsub!(/\n/, '\\n')
      request
  end
     

  def rsa_public_key1(data)
    public_key_file = 'public1.pem'
    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
    encrypted_string = Base64.encode64(public_key.public_encrypt(data))

    encrypted_string
  end

  def rsa_private_key2(cipertext)
    private_key_file = 'private2.pem'
    password = "ZXhwZXJ0aXph\n"
    encrypted_string = cipertext
    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file), Base64.decode64(password))
    string = private_key.private_decrypt(Base64.decode64(encrypted_string))

    string
  end

  def aes_encrypt(data)
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    key = cipher.random_key
    iv = cipher.random_iv
    cipertext = Base64.encode64(cipher.update(data) + cipher.final)
    [cipertext, key, iv]
  end

  def aes_decrypt(cipertext, key, iv)
    decipher = OpenSSL::Cipher::AES.new(256, :CBC)
    decipher.decrypt
    decipher.key = key
    decipher.iv = iv
    plain = decipher.update(Base64.decode64(cipertext)) + decipher.final
    plain
  end
end
