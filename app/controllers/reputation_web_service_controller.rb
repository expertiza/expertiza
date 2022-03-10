require 'json'
require 'uri'
require 'net/http'
require 'openssl'
require 'base64'

class ReputationWebServiceController < ApplicationController
  include AuthorizationHelper

  @@request_body = ''
  @@response_body = ''
  @@assignment_id = ''
  @@another_assignment_id = ''
  @@round_num = ''
  @@algorithm = ''
  @@additional_info = ''
  @@response = ''

  def action_allowed?
    current_user_has_ta_privileges?
  end

  # db query, return peer reviews
  def db_query(assignment_id, round_num, has_topic, another_assignment_id = 0)
    raw_data_array = []
    assignment_ids = []
    assignment_ids << assignment_id
    assignment_ids << another_assignment_id unless another_assignment_id.zero?
    ReviewResponseMap.where('reviewed_object_id in (?) and calibrate_to = ?', assignment_ids, false).each do |response_map|
      reviewer = response_map.reviewer.user
      team = AssignmentTeam.find(response_map.reviewee_id)
      topic_condition = ((has_topic && (SignedUpTeam.where(team_id: team.id).first.is_waitlisted == false)) || !has_topic)
      last_valid_response = response_map.response.select { |r| r.round == round_num }.max
      valid_response = [last_valid_response] unless last_valid_response.nil?
      next unless (topic_condition == true) && !valid_response.nil? && !valid_response.empty?

      valid_response.each do |response|
        answers = Answer.where(response_id: response.id)
        max_question_score = begin
                               answers.first.question.questionnaire.max_question_score
                             rescue StandardError
                               1
                             end
        temp_sum = 0
        weight_sum = 0
        valid_answer = answers.select { |a| (a.question.type == 'Criterion') && !a.answer.nil? }
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
  def db_query_with_quiz_score(assignment_id, another_assignment_id = 0)
    raw_data_array = []
    assignment_ids = []
    assignment_ids << assignment_id
    assignment_ids << another_assignment_id unless another_assignment_id.zero?
    teams = AssignmentTeam.where('parent_id in (?)', assignment_ids)
    team_ids = []
    teams.each { |team| team_ids << team.id }
    quiz_questionnnaires = QuizQuestionnaire.where('instructor_id in (?)', team_ids)
    quiz_questionnnaire_ids = []
    quiz_questionnnaires.each { |questionnaire| quiz_questionnnaire_ids << questionnaire.id }
    QuizResponseMap.where('reviewed_object_id in (?)', quiz_questionnnaire_ids).each do |response_map|
      quiz_score = response_map.quiz_score
      participant = Participant.find(response_map.reviewer_id)
      raw_data_array << [participant.user_id, response_map.reviewee_id, quiz_score]
    end
    raw_data_array
  end

  def json_generator(assignment_id, another_assignment_id = 0, round_num = 2, type = 'peer review grades')
    assignment = Assignment.find_by(id: assignment_id)
    has_topic = !SignUpTopic.where(assignment_id: assignment_id).empty?

    if type == 'peer review grades'
      @results = db_query(assignment.id, round_num, has_topic, another_assignment_id)
    elsif type == 'quiz scores'
      @results = db_query_with_quiz_score(assignment.id, another_assignment_id)
    end
    request_body = {}
    @results.each_with_index do |record, _index|
      request_body['submission' + record[1].to_s] = {} unless request_body.key?('submission' + record[1].to_s)
      request_body['submission' + record[1].to_s]['stu' + record[0].to_s] = record[2]
    end
    # sort the 2-dimension hash
    request_body.each { |k, v| request_body[k] = v.sort.to_h }
    request_body.sort.to_h
  end

  def client
    @request_body = @@request_body
    @response_body = @@response_body
    @max_assignment_id = Assignment.last.id
    @assignment = begin
                    Assignment.find(@@assignment_id)
                  rescue StandardError
                    nil
                  end
    @another_assignment = begin
                            Assignment.find(@@another_assignment_id)
                          rescue StandardError
                            nil
                          end
    @round_num = @@round_num
    @algorithm = @@algorithm
    @additional_info = @@additional_info
    @response = @@response
  end

  def encrypt_request_body(plain_data)

    # AES symmetric algorithm encrypts raw data
    aes_encrypted_request_data = aes_encrypt(plain_data)
    plain_data = aes_encrypted_request_data[0]

    # RSA asymmetric algorithm encrypts keys of AES
    encrypted_key = rsa_public_key1(aes_encrypted_request_data[1])
    encrypted_vi = rsa_public_key1(aes_encrypted_request_data[2])
    # fixed length 350
    
    plain_data.prepend('", "data":"')
    plain_data.prepend(encrypted_vi)
    plain_data.prepend(encrypted_key)
  end

  def format_into_JSON(data)
    data.prepend('{"keys":"')
    data << '"}'
    data.gsub!(/\n/, '\\n')
  end

  def decrypt_response(encrypted_data)
    encrypted_data = JSON.parse(encrypted_data)
    key = rsa_private_key2(encrypted_data['keys'][0, 350])
    vi = rsa_private_key2(encrypted_data['keys'][350, 350])
    # AES symmetric algorithm decrypts data
    aes_encrypted_response_data = encrypted_data['data']
    decrypted_data = aes_decrypt(aes_encrypted_response_data, key, vi)
  end

  def update_participants(response)
    JSON.parse(response.body.to_s).each do |alg, list|
      next unless alg == 'Hamer' || alg == 'Lauw'
      list.each do |id, rep|
        Participant.find_by(user_id: id).update(alg.to_sym => rep) unless /leniency/ =~ id.to_s
      end
    end
  end

  def process_response_body(response)

    
    # Decryption
    response.body = decrypt_response(response.body)
   
    
    @@response = response
    @@response_body = response.body

    update_participants(response)
    redirect_to action: 'client'
  end

  def add_expert_grades(body)
    @@additional_info = 'add expert grades'
    case params[:assignment_id]
    when '724' # expert grades of Wiki 1a (724)
      if params[:another_assignment_id].to_i.zero?
        body.prepend('"expert_grades": {"submission23967":93,"submission23969":89,"submission23971":95,"submission23972":86,"submission23973":91,"submission23975":94,"submission23979":90,"submission23980":94,"submission23981":87,"submission23982":79,"submission23983":91,"submission23986":92,"submission23987":91,"submission23988":93,"submission23991":98,"submission23992":91,"submission23994":87,"submission23995":93,"submission23998":92,"submission23999":87,"submission24000":93,"submission24001":93,"submission24006":96,"submission24007":87,"submission24008":92,"submission24009":92,"submission24010":93,"submission24012":94,"submission24013":96,"submission24016":91,"submission24018":93,"submission24024":96,"submission24028":88,"submission24031":94,"submission24040":93,"submission24043":95,"submission24044":91,"submission24046":95,"submission24051":92},')
      else # expert grades of Wiki 1a and 1b (724, 733)
        body.prepend('"expert_grades": {"submission23967":93, "submission23969":89, "submission23971":95, "submission23972":86, "submission23973":91, "submission23975":94, "submission23979":90, "submission23980":94, "submission23981":87, "submission23982":79, "submission23983":91, "submission23986":92, "submission23987":91, "submission23988":93, "submission23991":98, "submission23992":91, "submission23994":87, "submission23995":93, "submission23998":92, "submission23999":87, "submission24000":93, "submission24001":93, "submission24006":96, "submission24007":87, "submission24008":92, "submission24009":92, "submission24010":93, "submission24012":94, "submission24013":96, "submission24016":91, "submission24018":93, "submission24024":96, "submission24028":88, "submission24031":94, "submission24040":93, "submission24043":95, "submission24044":91, "submission24046":95, "submission24051":92, "submission24100":90, "submission24079":92, "submission24298":86, "submission24545":92, "submission24082":96, "submission24080":86, "submission24284":92, "submission24534":93, "submission24285":94, "submission24297":91},')
      end
    when '735' # expert grades of program 1 (735)
      body.prepend('"expert_grades": {"submission24083":96.084,"submission24085":88.811,"submission24086":100,"submission24087":100,"submission24088":92.657,"submission24091":96.783,"submission24092":90.21,"submission24093":100,"submission24097":90.909,"submission24098":98.601,"submission24101":99.301,"submission24278":98.601,"submission24279":72.727,"submission24281":54.476,"submission24289":94.406,"submission24291":99.301,"submission24293":93.706,"submission24296":98.601,"submission24302":83.217,"submission24303":91.329,"submission24305":100,"submission24307":100,"submission24308":100,"submission24311":95.804,"submission24313":91.049,"submission24314":100,"submission24315":97.483,"submission24316":91.608,"submission24317":98.182,"submission24320":90.21,"submission24321":90.21,"submission24322":98.601},')
    when '754' # expert grades of Wiki contribution (754)
      body.prepend('"expert_grades": {"submission25030":95,"submission25031":92,"submission25033":88,"submission25034":98,"submission25035":100,"submission25037":95,"submission25038":95,"submission25039":93,"submission25040":96,"submission25041":90,"submission25042":100,"submission25046":95,"submission25049":90,"submission25050":88,"submission25053":91,"submission25054":96,"submission25055":94,"submission25059":96,"submission25071":85,"submission25082":100,"submission25086":95,"submission25097":90,"submission25098":85,"submission25102":97,"submission25103":94,"submission25105":98,"submission25114":95,"submission25115":94},')
    when '756' # expert grades of Wikipedia contribution (756)
      body.prepend('"expert_grades": {"submission25107":76.6667,"submission25109":83.3333},')
    end
  end

  def add_quiz_scores(body)
    @@additional_info = 'add quiz scores'
    quiz_str = json_generator(params[:assignment_id].to_i, params[:another_assignment_id].to_i, params[:round_num].to_i, 'quiz scores').to_json
    quiz_str[0] = ''
    quiz_str.prepend('"quiz_scores":{')
    quiz_str += ','
    quiz_str = quiz_str.gsub('"N/A"', '20.0')
    body.prepend(quiz_str)
  end

  def add_hamer_reputation_values
    @@additional_info = 'add initial hamer reputation values'
  end

  def add_lauw_reputation_values
    @@additional_info = 'add initial lauw reputation values'
  end

  def prepare_request_body
    req = Net::HTTP::Post.new('/reputation/calculations/reputation_algorithms', initheader: { 'Content-Type' => 'application/json', 'charset' => 'utf-8' })
    curr_assignment_id = (params[:assignment_id].empty? ? '724' : params[:assignment_id])
    req.body = json_generator(curr_assignment_id, params[:another_assignment_id].to_i, params[:round_num].to_i, 'peer review grades').to_json
    req.body[0] = '' # remove the first '{'
    @@assignment_id = params[:assignment_id]
    @@round_num = params[:round_num]
    @@algorithm = params[:algorithm]
    @@another_assignment_id = params[:another_assignment_id]

    if params[:checkbox][:expert_grade] == 'Add expert grades'
      req.body = add_expert_grades(req.body)
    elsif params[:checkbox][:hamer] == 'Add initial Hamer reputation values'
      add_hamer_reputation_values
    elsif params[:checkbox][:lauw] == 'Add initial Lauw reputation values'
      add_lauw_reputation_values
    elsif params[:checkbox][:quiz] == 'Add quiz scores'
      add_quiz_scores(req.body)
    else
      @@additional_info = ''
    end

   
    req.body.prepend('{')
    @@request_body = req.body
    # Encrypting the request body data
    req.body = encrypt_request_body(req.body)
   
    # request body should be in JSON format.
    req.body = format_into_JSON(req.body)
    req
  end

  def send_post_request
    req = prepare_request_body
    response = Net::HTTP.new('peerlogic.csc.ncsu.edu').start { |http| http.request(req) }
    process_response_body(response)
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
