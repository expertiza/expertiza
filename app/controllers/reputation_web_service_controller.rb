require 'json'
require 'uri'
require 'net/http'
require 'openssl'
require 'base64'

class ReputationWebServiceController < ApplicationController
  @@request_body = ''
  @@response_body = ''
  @@assignment_id = ''
  @@another_assignment_id = ''
  @@round_num = ''
  @@algorithm = ''
  @@additional_info = ''
  @@response = ''

  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
  end

  # normal db query, return peer review grades
  def db_query(assignment_id, another_assignment_id = 0, round_num, hasTopic)
    # 	  query="SELECT U.id, RM.reviewee_id as submission_id, "+
    # 		    "sum(A.answer * Q.weight) / sum(QN.max_question_score * Q.weight) * 100 as total_score "+
    # 			# new way to calculate the grades of coding artifacts
    # 			#"100 - SUM((QN.max_question_score-A.answer) * Q.weight) AS total_score "+
    # 			"from answers A  "+
    # 			"inner join questions Q on A.question_id = Q.id "+
    # 			"inner join questionnaires QN on Q.questionnaire_id = QN.id "+
    # 			"inner join responses R on A.response_id = R.id "+
    # 			"inner join response_maps RM on R.map_id = RM.id "+
    # 			"inner join participants P on P.id = RM.reviewer_id "+
    # 			"inner join users U on U.id = P.user_id "+
    # 			"inner join teams T on T.id = RM.reviewee_id "
    # 			query += "inner join signed_up_teams SU_team on SU_team.team_id = T.id " if hasTopic == true
    # 			query += "where RM.type='ReviewResponseMap' "+
    # 			"and RM.reviewed_object_id = "+  assignment_id.to_s + " " +
    # 			"and A.answer is not null "+
    # 			"and Q.type ='Criterion' "+
    # 			#If one assignment is varying rubric by round (724, 733, 736) or 2-round peer review with (735),
    # 			#the round field in response records corresponding to ReviewResponseMap will be 1 or 2, will not be null.
    # 			"and R.round = 2 "
    # 			query+="and SU_team.is_waitlisted = 0 " if hasTopic == true
    # 			query+="group by RM.id "+
    # 			"order by RM.reviewee_id"
    #
    #         result = ActiveRecord::Base.connection.select_all(query)
    raw_data_array = []
    assignment_ids = []
    assignment_ids << assignment_id
    assignment_ids << another_assignment_id unless another_assignment_id == 0
    ReviewResponseMap.where(['reviewed_object_id in (?) and calibrate_to = ?', assignment_ids, false]).each do |response_map|
      reviewer = response_map.reviewer.user
      team = AssignmentTeam.find(response_map.reviewee_id)
      topic_condition = ((hasTopic and SignedUpTeam.where(team_id: team.id).first.is_waitlisted == false) or !hasTopic)
      last_valid_response = response_map.response.select {|r| r.round == round_num }.sort.last
      valid_response = [last_valid_response] unless last_valid_response.nil?
      next unless topic_condition == true and !valid_response.nil? and !valid_response.empty?
      valid_response.each do |response|
        answers = Answer.where(response_id: response.id)
        max_question_score = answers.first.question.questionnaire.max_question_score
        temp_sum = 0
        weight_sum = 0
        valid_answer = answers.select {|a| a.question.type == 'Criterion' and !a.answer.nil? }
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
    assignment_ids << another_assignment_id unless another_assignment_id == 0
    teams = AssignmentTeam.where(['parent_id in (?)', assignment_ids])
    team_ids = []
    teams.each {|team| team_ids << team.id }
    quiz_questionnnaires = QuizQuestionnaire.where(['instructor_id in (?)', team_ids])
    quiz_questionnnaire_ids = []
    quiz_questionnnaires.each {|questionnaire| quiz_questionnnaire_ids << questionnaire.id }
    QuizResponseMap.where(['reviewed_object_id in (?)', quiz_questionnnaire_ids]).each do |response_map|
      quiz_score = response_map.quiz_score
      participant = Participant.find(response_map.reviewer_id)
      raw_data_array << [participant.user_id, response_map.reviewee_id, quiz_score]
    end
    raw_data_array
  end

  def json_generator(assignment_id, another_assignment_id = 0, round_num = 2, type = 'peer review grades')
    assignment = Assignment.find_by_id(assignment_id)
    has_topic = !SignUpTopic.where(assignment_id: assignment_id).empty?

    if type == 'peer review grades'
      @results = db_query(assignment.id, another_assignment_id, round_num, has_topic)
    elsif type == 'quiz scores'
      @results = db_query_with_quiz_score(assignment.id, another_assignment_id)
    end
    request_body = {}
    inner_msg = {}
    @results.each_with_index do |record, _index|
      unless request_body.key?('submission' + record[1].to_s)
        request_body['submission' + record[1].to_s] = {}
      end
      request_body['submission' + record[1].to_s]['stu' + record[0].to_s] = record[2]
    end
    # sort the 2-dimention hash
    request_body.each {|k, v| request_body[k] = v.sort.to_h }
    request_body.sort.to_h
  end

  def client
    @request_body = @@request_body
    @response_body = @@response_body
    @max_assignment_id = Assignment.last.id
    @assignment = Assignment.find(@@assignment_id) rescue nil
    @another_assignment = Assignment.find(@@another_assignment_id) rescue nil
    @round_num = @@round_num
    @algorithm = @@algorithm
    @additional_info = @@additional_info
    @response = @@response
  end

  def send_post_request
    # https://www.socialtext.net/open/very_simple_rest_in_ruby_part_3_post_to_create_a_new_workspace
    req = Net::HTTP::Post.new('/reputation/calculations/reputation_algorithms', initheader = {'Content-Type' => 'application/json', 'charset' => 'utf-8'})
    curr_assignment_id = (params[:assignment_id].empty? ? '724' : params[:assignment_id])
    req.body = json_generator(curr_assignment_id, params[:another_assignment_id].to_i, params[:round_num].to_i, 'peer review grades').to_json
    req.body[0] = '' # remove the first '{'
    @@assignment_id = params[:assignment_id]
    @@round_num = params[:round_num]
    @@algorithm = params[:algorithm]
    @@another_assignment_id = params[:another_assignment_id]

    if params[:checkbox][:expert_grade] == 'Add expert grades'
      @@additional_info = 'add expert grades'
      case params[:assignment_id]
      when '724' # expert grades of Wiki 1a (724)
        if params[:another_assignment_id].to_i == 0
          req.body.prepend("\"expert_grades\": {\"submission23967\":93,\"submission23969\":89,\"submission23971\":95,\"submission23972\":86,\"submission23973\":91,\"submission23975\":94,\"submission23979\":90,\"submission23980\":94,\"submission23981\":87,\"submission23982\":79,\"submission23983\":91,\"submission23986\":92,\"submission23987\":91,\"submission23988\":93,\"submission23991\":98,\"submission23992\":91,\"submission23994\":87,\"submission23995\":93,\"submission23998\":92,\"submission23999\":87,\"submission24000\":93,\"submission24001\":93,\"submission24006\":96,\"submission24007\":87,\"submission24008\":92,\"submission24009\":92,\"submission24010\":93,\"submission24012\":94,\"submission24013\":96,\"submission24016\":91,\"submission24018\":93,\"submission24024\":96,\"submission24028\":88,\"submission24031\":94,\"submission24040\":93,\"submission24043\":95,\"submission24044\":91,\"submission24046\":95,\"submission24051\":92},")
        else # expert grades of Wiki 1a and 1b (724, 733)
          req.body.prepend("\"expert_grades\": {\"submission23967\":93, \"submission23969\":89, \"submission23971\":95, \"submission23972\":86, \"submission23973\":91, \"submission23975\":94, \"submission23979\":90, \"submission23980\":94, \"submission23981\":87, \"submission23982\":79, \"submission23983\":91, \"submission23986\":92, \"submission23987\":91, \"submission23988\":93, \"submission23991\":98, \"submission23992\":91, \"submission23994\":87, \"submission23995\":93, \"submission23998\":92, \"submission23999\":87, \"submission24000\":93, \"submission24001\":93, \"submission24006\":96, \"submission24007\":87, \"submission24008\":92, \"submission24009\":92, \"submission24010\":93, \"submission24012\":94, \"submission24013\":96, \"submission24016\":91, \"submission24018\":93, \"submission24024\":96, \"submission24028\":88, \"submission24031\":94, \"submission24040\":93, \"submission24043\":95, \"submission24044\":91, \"submission24046\":95, \"submission24051\":92, \"submission24100\":90, \"submission24079\":92, \"submission24298\":86, \"submission24545\":92, \"submission24082\":96, \"submission24080\":86, \"submission24284\":92, \"submission24534\":93, \"submission24285\":94, \"submission24297\":91},")
         end
      when '735' # expert grades of program 1 (735)
        req.body.prepend("\"expert_grades\": {\"submission24083\":96.084,\"submission24085\":88.811,\"submission24086\":100,\"submission24087\":100,\"submission24088\":92.657,\"submission24091\":96.783,\"submission24092\":90.21,\"submission24093\":100,\"submission24097\":90.909,\"submission24098\":98.601,\"submission24101\":99.301,\"submission24278\":98.601,\"submission24279\":72.727,\"submission24281\":54.476,\"submission24289\":94.406,\"submission24291\":99.301,\"submission24293\":93.706,\"submission24296\":98.601,\"submission24302\":83.217,\"submission24303\":91.329,\"submission24305\":100,\"submission24307\":100,\"submission24308\":100,\"submission24311\":95.804,\"submission24313\":91.049,\"submission24314\":100,\"submission24315\":97.483,\"submission24316\":91.608,\"submission24317\":98.182,\"submission24320\":90.21,\"submission24321\":90.21,\"submission24322\":98.601},")
      when '754' # expert grades of Wiki contribution (754)
        req.body.prepend("\"expert_grades\": {\"submission25030\":95,\"submission25031\":92,\"submission25033\":88,\"submission25034\":98,\"submission25035\":100,\"submission25037\":95,\"submission25038\":95,\"submission25039\":93,\"submission25040\":96,\"submission25041\":90,\"submission25042\":100,\"submission25046\":95,\"submission25049\":90,\"submission25050\":88,\"submission25053\":91,\"submission25054\":96,\"submission25055\":94,\"submission25059\":96,\"submission25071\":85,\"submission25082\":100,\"submission25086\":95,\"submission25097\":90,\"submission25098\":85,\"submission25102\":97,\"submission25103\":94,\"submission25105\":98,\"submission25114\":95,\"submission25115\":94},")
      when '756' # expert grades of Wikipedia contribution (756)
        req.body.prepend("\"expert_grades\": {\"submission25107\":76.6667,\"submission25109\":83.3333},")
      end
    elsif params[:checkbox][:hamer] == 'Add initial Hamer reputation values'
      @@additional_info = 'add initial hamer reputation values'
      case params[:hamer_assignment_id]
      when '724' # initial hamer reputation from Wiki 1a (724)
        if params[:another_hamer_assignment_id].to_i == 0
          req.body.prepend("\"initial_hamer_reputation\":{\"stu5787\":1.726,\"stu5790\":3.275,\"stu5791\":1.059,\"stu5796\":0.461,\"stu5797\":5.593,\"stu5800\":3.116,\"stu5807\":2.776,\"stu5808\":4.077,\"stu5810\":0.74,\"stu5815\":2.301,\"stu5818\":1.186,\"stu5825\":2.686,\"stu5826\":2.053,\"stu5827\":0.447,\"stu5828\":0.521,\"stu5829\":3.236,\"stu5835\":1.13,\"stu5837\":0.414,\"stu5839\":0.531,\"stu5843\":2.217,\"stu5846\":1.337,\"stu5849\":0.786,\"stu5850\":2.023,\"stu5855\":0.26,\"stu5856\":0.481,\"stu5857\":2.198,\"stu5859\":2.212,\"stu5860\":0.811,\"stu5862\":0.632,\"stu5864\":1.098,\"stu5866\":0.361,\"stu5867\":5.945,\"stu5870\":3.368,\"stu5874\":1.749,\"stu5880\":0.56},")
        elsif params[:another_hamer_assignment_id].to_i == 733 # initial hamer reputation of Wiki 1a and 1b (724, 733)
          req.body.prepend("\"initial_hamer_reputation\":{\"stu5687\":1.251,\"stu5787\":2.14,\"stu5790\":3.421,\"stu5791\":1.462,\"stu5795\":1.107,\"stu5796\":0.635,\"stu5797\":2.15,\"stu5800\":1.253,\"stu5801\":2.653,\"stu5804\":2.15,\"stu5806\":0.799,\"stu5807\":2.086,\"stu5808\":4.218,\"stu5810\":1.021,\"stu5811\":3.76,\"stu5814\":0.919,\"stu5815\":2.497,\"stu5818\":0.311,\"stu5820\":2.47,\"stu5822\":2.302,\"stu5824\":2.103,\"stu5825\":2.85,\"stu5826\":2.287,\"stu5827\":0.432,\"stu5828\":0.719,\"stu5829\":3.383,\"stu5830\":0.881,\"stu5832\":2.544,\"stu5835\":1.56,\"stu5837\":0.571,\"stu5839\":0.733,\"stu5840\":0.984,\"stu5841\":0.5,\"stu5843\":2.424,\"stu5846\":1.612,\"stu5848\":0.747,\"stu5849\":0.295,\"stu5850\":2.263,\"stu5855\":0.33,\"stu5856\":0.664,\"stu5857\":2.407,\"stu5859\":2.419,\"stu5860\":0.619,\"stu5862\":0.873,\"stu5863\":0.714,\"stu5864\":1.515,\"stu5866\":0.499,\"stu5867\":2.191,\"stu5868\":1.986,\"stu5869\":0.746,\"stu5870\":0.249,\"stu5871\":2.135,\"stu5873\":0.521,\"stu5874\":0.911,\"stu5875\":1.949,\"stu5876\":1.313,\"stu5880\":0.773},")
        end
      when '735' # initial hamer reputation from program 1 (735)
        req.body.prepend("\"initial_hamer_reputation\":{\"stu4381\":2.649,\"stu5415\":3.022,\"stu5687\":3.578,\"stu5787\":3.142,\"stu5788\":2.424,\"stu5789\":0.134,\"stu5790\":2.885,\"stu5792\":2.27,\"stu5793\":2.317,\"stu5794\":2.219,\"stu5795\":1.232,\"stu5796\":0.832,\"stu5797\":2.946,\"stu5798\":0.225,\"stu5799\":5.365,\"stu5800\":2.749,\"stu5801\":4.161,\"stu5802\":4.78,\"stu5803\":0.366,\"stu5804\":0.262,\"stu5805\":3.016,\"stu5806\":0.561,\"stu5807\":3.028,\"stu5808\":3.573,\"stu5810\":3.664,\"stu5812\":2.638,\"stu5813\":2.621,\"stu5814\":3.035,\"stu5815\":2.985,\"stu5816\":0.11,\"stu5817\":2.16,\"stu5818\":0.448,\"stu5821\":0.294,\"stu5822\":1.874,\"stu5823\":3.339,\"stu5824\":3.597,\"stu5825\":4.033,\"stu5826\":2.962,\"stu5827\":1.49,\"stu5828\":3.208,\"stu5830\":1.211,\"stu5832\":0.406,\"stu5833\":3.04,\"stu5836\":3.396,\"stu5838\":4.519,\"stu5839\":2.974,\"stu5840\":1.952,\"stu5843\":3.515,\"stu5844\":0.627,\"stu5845\":2.355,\"stu5846\":3.604,\"stu5847\":3.847,\"stu5848\":1.488,\"stu5849\":2.078,\"stu5850\":2.957,\"stu5851\":2.774,\"stu5852\":2.345,\"stu5853\":1.717,\"stu5854\":2.275,\"stu5855\":2.216,\"stu5856\":1.4,\"stu5857\":3.463,\"stu5858\":3.132,\"stu5859\":3.327,\"stu5860\":0.965,\"stu5861\":1.683,\"stu5862\":1.646,\"stu5863\":0.457,\"stu5864\":3.901,\"stu5866\":2.402,\"stu5867\":1.495,\"stu5868\":0.198,\"stu5869\":1.434,\"stu5870\":0.43,\"stu5871\":0.654,\"stu5872\":0.854,\"stu5873\":2.645,\"stu5874\":1.988,\"stu5875\":0.089,\"stu5876\":3.438,\"stu5878\":3.763,\"stu5880\":2.444,\"stu5881\":0.316},")
      when '736' # initial hamer reputation from Calibration assignment (736)
        req.body.prepend("\"initial_hamer_reputation\":{\"stu4381\":3.5,\"stu5415\":2.34,\"stu5687\":2.421,\"stu5787\":2.821,\"stu5788\":2.397,\"stu5789\":2.307,\"stu5790\":0.266,\"stu5792\":1.112,\"stu5793\":2.654,\"stu5794\":1.98,\"stu5795\":1.04,\"stu5796\":2.077,\"stu5797\":2.839,\"stu5798\":3.365,\"stu5799\":0.842,\"stu5800\":3.373,\"stu5801\":3.253,\"stu5802\":1.355,\"stu5803\":3.107,\"stu5804\":2.061,\"stu5805\":3.013,\"stu5806\":0.608,\"stu5807\":1.661,\"stu5808\":3.04,\"stu5810\":1.045,\"stu5813\":0.461,\"stu5814\":0.618,\"stu5815\":3.374,\"stu5817\":1.401,\"stu5818\":0.085,\"stu5821\":2.889,\"stu5822\":0.704,\"stu5823\":3.112,\"stu5824\":3.31,\"stu5825\":2.955,\"stu5826\":3.082,\"stu5827\":0.39,\"stu5828\":2.539,\"stu5829\":0.174,\"stu5830\":3.604,\"stu5832\":3.706,\"stu5833\":2.747,\"stu5835\":0.543,\"stu5836\":2.173,\"stu5838\":2.766,\"stu5839\":2.874,\"stu5840\":0.259,\"stu5841\":2.919,\"stu5843\":2.837,\"stu5846\":2.271,\"stu5847\":1.487,\"stu5848\":2.416,\"stu5849\":0.401,\"stu5850\":2.401,\"stu5851\":2.944,\"stu5852\":1.653,\"stu5853\":0.619,\"stu5854\":2.046,\"stu5855\":0.451,\"stu5856\":0.763,\"stu5857\":2.505,\"stu5858\":2.525,\"stu5859\":2.521,\"stu5860\":2.392,\"stu5861\":3.142,\"stu5862\":0.852,\"stu5863\":1.572,\"stu5864\":3.334,\"stu5866\":2.534,\"stu5867\":0.292,\"stu5869\":1.096,\"stu5870\":0.095,\"stu5871\":1.252,\"stu5872\":2.271,\"stu5873\":0.944,\"stu5874\":1.24,\"stu5875\":1.603,\"stu5876\":3.091,\"stu5878\":3.593,\"stu5880\":0.878,\"stu5881\":4.198},")
      when '754' # initial hamer reputation from (754)
        req.body.prepend("\"initial_hamer_reputation\":{\"stu5498\":0.473,\"stu5884\":2.732,\"stu5892\":0.904,\"stu5899\":2.139,\"stu5900\":0.956,\"stu5913\":2.997,\"stu5918\":2.929,\"stu5920\":0.749,\"stu5931\":2.093,\"stu5933\":1.156,\"stu6361\":2.498,\"stu6362\":0.286,\"stu6364\":2.736,\"stu6368\":0.516,\"stu6370\":2.891,\"stu6371\":0.398,\"stu6372\":2.034,\"stu6373\":2.87,\"stu6374\":0.768,\"stu6375\":2.113,\"stu6376\":2.991,\"stu6378\":2.365,\"stu6380\":2.356,\"stu6381\":2.759,\"stu6382\":1.542,\"stu6385\":0.919,\"stu6387\":0.336,\"stu6388\":2.08,\"stu6389\":0.946,\"stu6390\":0.879,\"stu6391\":1.574,\"stu6392\":0.265,\"stu6394\":1.538,\"stu6397\":0.528,\"stu6399\":2.287,\"stu6400\":0.37,\"stu6403\":2.973,\"stu6404\":2.459,\"stu6405\":3.113,\"stu6410\":0.178,\"stu6414\":2.279,\"stu6415\":2.797,\"stu6417\":2.672,\"stu6420\":2.383,\"stu6423\":0.174,\"stu6425\":3.047,\"stu6426\":2.137,\"stu6429\":3.0,\"stu6430\":2.017,\"stu6433\":3.722,\"stu6468\":2.713,\"stu6469\":0.345,\"stu6471\":2.795,\"stu6472\":2.419},")
      when '756' # initial hamer reputation from Calibration assignment (756)
        req.body.prepend("\"initial_hamer_reputation\":{\"stu5498\":1.402,\"stu5884\":2.174,\"stu5892\":3.009,\"stu5899\":2.542,\"stu5900\":6.397,\"stu5913\":3.331,\"stu5918\":0.499,\"stu5920\":2.095,\"stu5931\":0.449,\"stu5933\":1.122,\"stu6360\":0.249,\"stu6361\":3.009,\"stu6362\":0.623,\"stu6364\":0.614,\"stu6368\":3.331,\"stu6370\":2.664,\"stu6371\":2.095,\"stu6372\":0.863,\"stu6373\":0.774,\"stu6374\":1.122,\"stu6375\":1.726,\"stu6376\":0.184,\"stu6378\":2.663,\"stu6380\":2.174,\"stu6381\":2.174,\"stu6382\":2.095,\"stu6385\":3.331,\"stu6387\":1.32,\"stu6389\":2.174,\"stu6390\":3.331,\"stu6391\":0.66,\"stu6392\":0.154,\"stu6397\":1.726,\"stu6399\":2.542,\"stu6400\":2.095,\"stu6403\":0.222,\"stu6404\":1.402,\"stu6410\":1.32,\"stu6414\":2.663,\"stu6415\":0.623,\"stu6417\":2.664,\"stu6420\":2.174,\"stu6423\":1.246,\"stu6425\":6.397,\"stu6426\":2.664,\"stu6429\":2.663,\"stu6430\":1.402,\"stu6433\":2.542,\"stu6468\":2.256,\"stu6469\":0.897,\"stu6471\":0.449,\"stu6472\":0.66},")
      when '764' # initial hamer reputation from (764)
        req.body.prepend("\"initial_hamer_reputation\":{\"stu5498\":1.314,\"stu5884\":1.04,\"stu5892\":3.303,\"stu5899\":0.335,\"stu5900\":0.373,\"stu5913\":2.609,\"stu5918\":0.33,\"stu5920\":3.417,\"stu5931\":2.402,\"stu5933\":2.522,\"stu6361\":0.619,\"stu6362\":1.548,\"stu6364\":0.619,\"stu6368\":2.486,\"stu6370\":1.405,\"stu6371\":1.044,\"stu6372\":1.92,\"stu6373\":2.764,\"stu6374\":0.263,\"stu6375\":2.144,\"stu6376\":0.788,\"stu6378\":2.642,\"stu6380\":2.218,\"stu6381\":2.783,\"stu6382\":2.551,\"stu6385\":2.684,\"stu6387\":2.588,\"stu6388\":2.222,\"stu6389\":0.779,\"stu6390\":0.552,\"stu6391\":2.179,\"stu6392\":1.52,\"stu6394\":2.689,\"stu6397\":2.87,\"stu6399\":2.074,\"stu6400\":0.287,\"stu6403\":0.455,\"stu6404\":3.086,\"stu6410\":2.547,\"stu6415\":0.221,\"stu6417\":0.324,\"stu6420\":2.408,\"stu6423\":2.036,\"stu6425\":2.667,\"stu6426\":0.758,\"stu6429\":2.257,\"stu6430\":0.436,\"stu6433\":0.664,\"stu6468\":2.453,\"stu6469\":2.423,\"stu6471\":2.401,\"stu6472\":0.69},")
      when '765' # initial hamer reputation from (765)
        req.body.prepend("\"initial_hamer_reputation\":{\"stu5498\":3.005,\"stu5884\":2.36,\"stu5892\":2.358,\"stu5899\":0.724,\"stu5900\":0.318,\"stu5918\":0.203,\"stu5920\":0.455,\"stu5931\":0.771,\"stu5933\":0.188,\"stu6361\":2.146,\"stu6362\":0.329,\"stu6364\":2.82,\"stu6368\":2.109,\"stu6370\":2.857,\"stu6371\":1.341,\"stu6372\":0.317,\"stu6373\":2.511,\"stu6374\":2.888,\"stu6375\":1.1,\"stu6378\":2.463,\"stu6380\":0.561,\"stu6381\":3.226,\"stu6382\":0.353,\"stu6385\":1.931,\"stu6387\":2.511,\"stu6388\":0.852,\"stu6390\":2.291,\"stu6391\":0.257,\"stu6392\":2.157,\"stu6397\":2.46,\"stu6399\":2.559,\"stu6400\":0.23,\"stu6403\":2.516,\"stu6404\":3.014,\"stu6405\":1.586,\"stu6410\":3.599,\"stu6414\":2.356,\"stu6415\":1.95,\"stu6417\":1.892,\"stu6420\":3.489,\"stu6423\":1.065,\"stu6425\":2.313,\"stu6426\":2.397,\"stu6429\":2.418,\"stu6430\":3.779,\"stu6433\":3.088,\"stu6468\":2.566,\"stu6469\":2.593,\"stu6471\":2.301,\"stu6472\":2.175},")
      # 754 round1
      when '1'
        req.body.prepend("\"initial_hamer_reputation\":{\"stu5498\":2.25,\"stu5884\":0.691,\"stu5892\":1.468,\"stu5899\":0.618,\"stu5900\":3.03,\"stu5913\":2.437,\"stu5918\":2.52,\"stu5920\":1.477,\"stu5931\":1.084,\"stu5933\":0.689,\"stu6361\":1.259,\"stu6362\":0.847,\"stu6364\":2.156,\"stu6368\":1.362,\"stu6370\":2.17,\"stu6371\":2.143,\"stu6372\":0.379,\"stu6373\":1.888,\"stu6374\":2.161,\"stu6375\":0.626,\"stu6376\":2.34,\"stu6378\":0.483,\"stu6380\":3.399,\"stu6381\":1.18,\"stu6382\":1.084,\"stu6385\":4.08,\"stu6387\":2.347,\"stu6388\":0.264,\"stu6389\":0.704,\"stu6390\":2.913,\"stu6391\":2.405,\"stu6392\":1.509,\"stu6394\":2.612,\"stu6397\":2.847,\"stu6399\":0.821,\"stu6400\":1.075,\"stu6403\":2.613,\"stu6404\":1.826,\"stu6405\":2.591,\"stu6410\":0.257,\"stu6414\":2.577,\"stu6415\":1.42,\"stu6417\":1.902,\"stu6420\":2.062,\"stu6423\":2.506,\"stu6425\":1.111,\"stu6426\":1.474,\"stu6429\":1.416,\"stu6430\":2.964,\"stu6431\":2.451,\"stu6433\":3.396,\"stu6468\":1.467,\"stu6469\":0.154,\"stu6471\":0.125,\"stu6472\":3.058},")
      # 764 round 1
      when '2'
        req.body.prepend("\"initial_hamer_reputation\":{\"stu5498\":0.68,\"stu5884\":1.015,\"stu5892\":2.698,\"stu5899\":0.922,\"stu5900\":0.884,\"stu5913\":3.145,\"stu5918\":2.219,\"stu5920\":2.943,\"stu5931\":2.959,\"stu5933\":0.595,\"stu6361\":0.977,\"stu6362\":2.479,\"stu6364\":2.618,\"stu6368\":2.148,\"stu6370\":2.493,\"stu6371\":0.651,\"stu6372\":2.416,\"stu6373\":0.222,\"stu6374\":0.925,\"stu6375\":3.305,\"stu6376\":2.984,\"stu6378\":2.103,\"stu6380\":1.502,\"stu6381\":1.981,\"stu6382\":2.895,\"stu6385\":3.0,\"stu6387\":1.374,\"stu6388\":0.9,\"stu6389\":0.139,\"stu6390\":2.444,\"stu6391\":0.748,\"stu6392\":2.311,\"stu6397\":1.841,\"stu6399\":2.502,\"stu6400\":2.258,\"stu6403\":2.1,\"stu6404\":2.703,\"stu6405\":2.407,\"stu6410\":2.74,\"stu6414\":2.188,\"stu6415\":0.227,\"stu6417\":3.288,\"stu6420\":2.812,\"stu6423\":2.645,\"stu6425\":0.216,\"stu6426\":2.615,\"stu6429\":2.41,\"stu6430\":0.129,\"stu6433\":3.016,\"stu6468\":0.502,\"stu6469\":2.865,\"stu6471\":2.637,\"stu6472\":1.2},")
      # 765 round 1
      when '3'
        req.body.prepend("\"initial_hamer_reputation\":{\"stu5498\":1.81,\"stu5884\":2.77,\"stu5892\":2.821,\"stu5899\":2.84,\"stu5900\":3.067,\"stu5913\":4.235,\"stu5918\":0.719,\"stu5920\":2.744,\"stu5931\":2.708,\"stu5933\":0.085,\"stu6361\":1.398,\"stu6362\":0.412,\"stu6364\":3.449,\"stu6368\":2.916,\"stu6370\":0.311,\"stu6371\":1.474,\"stu6372\":2.469,\"stu6373\":2.727,\"stu6374\":1.741,\"stu6375\":0.093,\"stu6378\":0.485,\"stu6380\":1.78,\"stu6381\":3.577,\"stu6382\":1.23,\"stu6385\":2.809,\"stu6387\":2.842,\"stu6388\":2.465,\"stu6389\":3.023,\"stu6390\":1.039,\"stu6391\":0.951,\"stu6392\":2.939,\"stu6394\":2.455,\"stu6397\":2.818,\"stu6399\":2.94,\"stu6400\":0.33,\"stu6403\":2.577,\"stu6405\":2.437,\"stu6410\":3.916,\"stu6414\":3.533,\"stu6415\":2.689,\"stu6417\":2.985,\"stu6420\":1.84,\"stu6423\":2.773,\"stu6425\":2.869,\"stu6426\":1.693,\"stu6429\":2.5,\"stu6430\":0.479,\"stu6433\":3.082,\"stu6468\":0.333,\"stu6469\":1.481,\"stu6471\":2.225,\"stu6472\":2.473},")
      # 772 round 1
      when '4'
        req.body.prepend("\"initial_hamer_reputation\":{\"stu5498\":1.731,\"stu5884\":3.226,\"stu5892\":0.875,\"stu5899\":2.478,\"stu5900\":0.845,\"stu5913\":2.577,\"stu5918\":2.507,\"stu5920\":2.911,\"stu5931\":1.786,\"stu5933\":0.345,\"stu6361\":0.472,\"stu6362\":0.323,\"stu6364\":3.273,\"stu6368\":2.813,\"stu6370\":2.1,\"stu6371\":1.585,\"stu6372\":2.179,\"stu6373\":2.71,\"stu6374\":2.104,\"stu6375\":0.964,\"stu6378\":1.194,\"stu6380\":2.818,\"stu6381\":2.097,\"stu6382\":3.865,\"stu6385\":0.11,\"stu6387\":0.925,\"stu6388\":1.744,\"stu6389\":3.679,\"stu6390\":2.341,\"stu6391\":2.268,\"stu6392\":3.04,\"stu6394\":1.151,\"stu6397\":3.067,\"stu6399\":1.035,\"stu6403\":1.813,\"stu6404\":0.129,\"stu6405\":3.134,\"stu6410\":2.16,\"stu6414\":2.986,\"stu6415\":0.13,\"stu6417\":2.961,\"stu6420\":2.611,\"stu6423\":3.652,\"stu6425\":2.589,\"stu6426\":0.448,\"stu6429\":2.258,\"stu6430\":4.778,\"stu6433\":1.269,\"stu6468\":2.439,\"stu6469\":2.127,\"stu6471\":2.672,\"stu6472\":3.108},")
      # 754 round2
      when '5'
        req.body.prepend("\"initial_hamer_reputation\":{\"stu5498\":0.473,\"stu5884\":2.732,\"stu5892\":0.904,\"stu5899\":2.139,\"stu5900\":0.956,\"stu5913\":2.997,\"stu5918\":2.929,\"stu5920\":0.749,\"stu5931\":2.093,\"stu5933\":1.156,\"stu6361\":2.498,\"stu6362\":0.286,\"stu6364\":2.736,\"stu6368\":0.516,\"stu6370\":2.891,\"stu6371\":0.398,\"stu6372\":2.034,\"stu6373\":2.87,\"stu6374\":0.768,\"stu6375\":2.113,\"stu6376\":2.991,\"stu6378\":2.365,\"stu6380\":2.356,\"stu6381\":2.759,\"stu6382\":1.542,\"stu6385\":0.919,\"stu6387\":0.336,\"stu6388\":2.08,\"stu6389\":0.946,\"stu6390\":0.879,\"stu6391\":1.574,\"stu6392\":0.265,\"stu6394\":1.538,\"stu6397\":0.528,\"stu6399\":2.287,\"stu6400\":0.37,\"stu6403\":2.973,\"stu6404\":2.459,\"stu6405\":3.113,\"stu6410\":0.178,\"stu6414\":2.279,\"stu6415\":2.797,\"stu6417\":2.672,\"stu6420\":2.383,\"stu6423\":0.174,\"stu6425\":3.047,\"stu6426\":2.137,\"stu6429\":3.0,\"stu6430\":2.017,\"stu6433\":3.722,\"stu6468\":2.713,\"stu6469\":0.345,\"stu6471\":2.795,\"stu6472\":2.419},")
      # 764 round2
      when '6'
        req.body.prepend("\"initial_hamer_reputation\":{\"stu5498\":1.314,\"stu5884\":1.04,\"stu5892\":3.303,\"stu5899\":0.335,\"stu5900\":0.373,\"stu5913\":2.609,\"stu5918\":0.33,\"stu5920\":3.417,\"stu5931\":2.402,\"stu5933\":2.522,\"stu6361\":0.619,\"stu6362\":1.548,\"stu6364\":0.619,\"stu6368\":2.486,\"stu6370\":1.405,\"stu6371\":1.044,\"stu6372\":1.92,\"stu6373\":2.764,\"stu6374\":0.263,\"stu6375\":2.144,\"stu6376\":0.788,\"stu6378\":2.642,\"stu6380\":2.218,\"stu6381\":2.783,\"stu6382\":2.551,\"stu6385\":2.684,\"stu6387\":2.588,\"stu6388\":2.222,\"stu6389\":0.779,\"stu6390\":0.552,\"stu6391\":2.179,\"stu6392\":1.52,\"stu6394\":2.689,\"stu6397\":2.87,\"stu6399\":2.074,\"stu6400\":0.287,\"stu6403\":0.455,\"stu6404\":3.086,\"stu6410\":2.547,\"stu6415\":0.221,\"stu6417\":0.324,\"stu6420\":2.408,\"stu6423\":2.036,\"stu6425\":2.667,\"stu6426\":0.758,\"stu6429\":2.257,\"stu6430\":0.436,\"stu6433\":0.664,\"stu6468\":2.453,\"stu6469\":2.423,\"stu6471\":2.401,\"stu6472\":0.69},")
      end
    elsif params[:checkbox][:lauw] == 'Add initial Lauw reputation values'
      @@additional_info = 'add initial lauw reputation values'
      case params[:lauw_assignment_id]
      when '724' # initial lauw reputation from Wiki 1a (724)
        if params[:another_lauw_assignment_id].to_i == 0
        # do nothing now
        elsif params[:another_lauw_assignment_id].to_i == 733 # initial lauw reputation of Wiki 1a and 1b (724, 733)
          req.body.prepend("\"initial_lauw_leniency\":{\"stu5687\":-0.018,\"stu5787\":-0.025,\"stu5790\":-0.004,\"stu5791\":0.05,\"stu5795\":-0.061,\"stu5796\":0.009,\"stu5797\":0.113,\"stu5800\":0.127,\"stu5801\":0.07,\"stu5804\":-0.131,\"stu5806\":0.084,\"stu5807\":-0.099,\"stu5808\":-0.002,\"stu5810\":-0.006,\"stu5811\":-0.014,\"stu5814\":0.04,\"stu5815\":0.03,\"stu5818\":-0.424,\"stu5820\":0.069,\"stu5822\":0.09,\"stu5824\":-0.131,\"stu5825\":0.042,\"stu5826\":0.076,\"stu5827\":0.113,\"stu5828\":-0.165,\"stu5829\":-0.04,\"stu5830\":0.09,\"stu5832\":0.08,\"stu5835\":0.07,\"stu5837\":0.035,\"stu5839\":-0.144,\"stu5840\":0.003,\"stu5841\":-0.343,\"stu5843\":-0.053,\"stu5846\":-0.031,\"stu5848\":0.14,\"stu5849\":-0.391,\"stu5850\":0.003,\"stu5855\":0.051,\"stu5856\":0.09,\"stu5857\":0.09,\"stu5859\":0.08,\"stu5860\":0.025,\"stu5862\":0.05,\"stu5863\":0.07,\"stu5864\":-0.144,\"stu5866\":-0.014,\"stu5867\":0.03,\"stu5868\":0.09,\"stu5869\":0.053,\"stu5870\":-0.087,\"stu5871\":0.1,\"stu5873\":0.051,\"stu5874\":-0.119,\"stu5875\":-0.165,\"stu5876\":0.127,\"stu5880\":0.01},")
        end
      when '735' # initial lauw reputation from program 1 (735)
        req.body.prepend("\"initial_lauw_leniency\":{\"stu4381\":-0.086,\"stu5415\":0.003,\"stu5687\":0.039,\"stu5787\":-0.029,\"stu5788\":-0.034,\"stu5789\":0.124,\"stu5790\":-0.006,\"stu5792\":-0.017,\"stu5793\":0.014,\"stu5794\":0.027,\"stu5795\":-0.001,\"stu5796\":-0.029,\"stu5797\":0.012,\"stu5798\":0.012,\"stu5799\":0.008,\"stu5800\":-0.009,\"stu5801\":0.003,\"stu5802\":0.015,\"stu5803\":-1.0,\"stu5804\":-1.0,\"stu5805\":-0.016,\"stu5806\":0.014,\"stu5807\":0.054,\"stu5808\":0.027,\"stu5810\":0.042,\"stu5812\":0.128,\"stu5813\":-0.066,\"stu5814\":0.084,\"stu5815\":-0.016,\"stu5816\":-1.0,\"stu5817\":-0.165,\"stu5818\":-0.248,\"stu5821\":-1.0,\"stu5822\":0.025,\"stu5823\":-0.076,\"stu5824\":0.054,\"stu5825\":0.018,\"stu5826\":0.0,\"stu5827\":0.014,\"stu5828\":-0.051,\"stu5830\":0.098,\"stu5832\":-0.038,\"stu5833\":0.098,\"stu5836\":0.067,\"stu5838\":-0.021,\"stu5839\":-0.068,\"stu5840\":-0.209,\"stu5843\":-0.022,\"stu5844\":-0.138,\"stu5845\":-0.072,\"stu5846\":-0.05,\"stu5847\":-0.011,\"stu5848\":0.014,\"stu5849\":0.098,\"stu5850\":-0.017,\"stu5851\":0.014,\"stu5852\":0.006,\"stu5853\":0.084,\"stu5854\":-0.242,\"stu5855\":0.023,\"stu5856\":0.018,\"stu5857\":-0.048,\"stu5858\":-0.066,\"stu5859\":0.025,\"stu5860\":-0.45,\"stu5861\":-0.04,\"stu5862\":0.033,\"stu5863\":0.0,\"stu5864\":-0.019,\"stu5866\":-0.001,\"stu5867\":-0.047,\"stu5868\":-0.303,\"stu5869\":-0.111,\"stu5870\":0.039,\"stu5871\":0.023,\"stu5872\":0.098,\"stu5873\":0.098,\"stu5874\":-0.034,\"stu5875\":-0.068,\"stu5876\":0.014,\"stu5878\":-0.05,\"stu5880\":0.09,\"stu5881\":0.069},")
      when '736' # initial lauw reputation from (736)
        req.body.prepend("\"initial_lauw_leniency\":{\"stu4381\":0.156,\"stu5415\":0.126,\"stu5687\":-0.048,\"stu5787\":-0.022,\"stu5788\":-0.11,\"stu5789\":-0.072,\"stu5790\":-0.045,\"stu5792\":0.015,\"stu5793\":-0.053,\"stu5794\":0.071,\"stu5795\":0.082,\"stu5796\":0.054,\"stu5797\":0.032,\"stu5798\":-0.057,\"stu5799\":0.067,\"stu5800\":0.11,\"stu5801\":-0.073,\"stu5802\":0.109,\"stu5803\":0.011,\"stu5804\":0.126,\"stu5805\":-0.136,\"stu5806\":-0.019,\"stu5807\":0.161,\"stu5808\":0.183,\"stu5810\":-0.266,\"stu5813\":0.029,\"stu5814\":0.076,\"stu5815\":0.095,\"stu5817\":-0.182,\"stu5818\":-0.872,\"stu5821\":0.074,\"stu5822\":0.054,\"stu5823\":0.025,\"stu5824\":-0.088,\"stu5825\":0.082,\"stu5826\":0.076,\"stu5827\":0.059,\"stu5828\":-0.017,\"stu5829\":-0.894,\"stu5830\":0.091,\"stu5832\":0.076,\"stu5833\":0.11,\"stu5835\":-0.456,\"stu5836\":-0.019,\"stu5838\":0.064,\"stu5839\":0.07,\"stu5840\":-0.689,\"stu5841\":-0.038,\"stu5843\":0.144,\"stu5846\":0.054,\"stu5847\":0.022,\"stu5848\":0.071,\"stu5849\":0.156,\"stu5850\":0.095,\"stu5851\":-0.005,\"stu5852\":0.054,\"stu5853\":0.081,\"stu5854\":0.109,\"stu5855\":-0.16,\"stu5856\":0.104,\"stu5857\":-0.02,\"stu5858\":-0.176,\"stu5859\":0.118,\"stu5860\":0.014,\"stu5861\":0.091,\"stu5862\":0.025,\"stu5863\":-0.333,\"stu5864\":0.028,\"stu5866\":0.11,\"stu5867\":-0.025,\"stu5869\":-0.248,\"stu5870\":-0.056,\"stu5871\":-0.192,\"stu5872\":0.101,\"stu5873\":-0.182,\"stu5874\":0.022,\"stu5875\":-0.162,\"stu5876\":0.134,\"stu5878\":-0.02,\"stu5880\":0.134,\"stu5881\":-0.016},")
      when '754' # initial lauw reputation from (754)
        req.body.prepend("\"initial_lauw_leniency\":{\"stu5498\":-0.143,\"stu5884\":0.025,\"stu5892\":-0.111,\"stu5899\":-0.039,\"stu5900\":0.068,\"stu5913\":-0.013,\"stu5918\":0.007,\"stu5920\":-0.07,\"stu5931\":-0.007,\"stu5933\":-0.056,\"stu6361\":-0.047,\"stu6362\":-0.204,\"stu6364\":0.01,\"stu6368\":0.026,\"stu6370\":0.004,\"stu6371\":-0.039,\"stu6372\":-0.027,\"stu6373\":0.043,\"stu6374\":0.027,\"stu6375\":-0.056,\"stu6376\":0.028,\"stu6378\":0.028,\"stu6380\":0.038,\"stu6381\":0.034,\"stu6382\":-0.036,\"stu6385\":-0.027,\"stu6387\":-0.095,\"stu6388\":0.043,\"stu6389\":-0.041,\"stu6390\":-0.137,\"stu6391\":-0.067,\"stu6392\":-0.02,\"stu6394\":0.087,\"stu6397\":-0.023,\"stu6399\":-0.045,\"stu6400\":-0.141,\"stu6403\":0.029,\"stu6404\":0.021,\"stu6405\":-0.007,\"stu6410\":-0.171,\"stu6414\":-0.06,\"stu6415\":0.058,\"stu6417\":0.025,\"stu6420\":-0.006,\"stu6423\":-0.164,\"stu6425\":0.021,\"stu6426\":-0.02,\"stu6429\":-0.004,\"stu6430\":0.014,\"stu6433\":-0.003,\"stu6468\":0.053,\"stu6469\":-0.229,\"stu6471\":0.045,\"stu6472\":0.025},")
      when '756' # initial lauw reputation from Calibration assignment (756)
        req.body.prepend("\"initial_lauw_leniency\":{\"stu5498\":0.138,\"stu5884\":0.107,\"stu5892\":-0.042,\"stu5899\":-0.042,\"stu5900\":0.0,\"stu5913\":0.038,\"stu5918\":0.107,\"stu5920\":-0.042,\"stu5931\":0.038,\"stu5933\":0.074,\"stu6360\":-0.136,\"stu6361\":-0.042,\"stu6362\":-0.316,\"stu6364\":-0.25,\"stu6368\":0.038,\"stu6370\":0.074,\"stu6371\":0.038,\"stu6372\":0.038,\"stu6373\":-0.087,\"stu6374\":0.074,\"stu6375\":0.107,\"stu6376\":0.038,\"stu6378\":0.074,\"stu6380\":0.107,\"stu6381\":0.0,\"stu6382\":-0.042,\"stu6385\":-0.042,\"stu6387\":0.038,\"stu6389\":0.0,\"stu6390\":-0.042,\"stu6391\":-0.136,\"stu6392\":-0.25,\"stu6397\":0.107,\"stu6399\":0.038,\"stu6400\":0.038,\"stu6403\":0.038,\"stu6404\":-0.19,\"stu6410\":0.038,\"stu6414\":0.0,\"stu6415\":-0.316,\"stu6417\":0.08,\"stu6420\":-0.15,\"stu6423\":0.107,\"stu6425\":0.0,\"stu6426\":0.074,\"stu6429\":-0.087,\"stu6430\":-0.19,\"stu6433\":-0.087,\"stu6468\":0.074,\"stu6469\":-0.25,\"stu6471\":-0.042,\"stu6472\":-0.136},")
      when '764' # initial lauw reputation from (764)
        req.body.prepend("\"initial_lauw_leniency\":{\"stu5498\":-0.269,\"stu5884\":-0.034,\"stu5892\":0.003,\"stu5899\":-0.039,\"stu5900\":0.18,\"stu5913\":-0.001,\"stu5918\":-0.472,\"stu5920\":0.011,\"stu5931\":0.009,\"stu5933\":0.076,\"stu6361\":-0.247,\"stu6362\":-0.081,\"stu6364\":-0.214,\"stu6368\":0.151,\"stu6370\":0.121,\"stu6371\":0.003,\"stu6372\":-0.093,\"stu6373\":0.003,\"stu6374\":-0.487,\"stu6375\":-0.143,\"stu6376\":-0.034,\"stu6378\":-0.072,\"stu6380\":0.086,\"stu6381\":-0.026,\"stu6382\":0.049,\"stu6385\":0.056,\"stu6387\":0.046,\"stu6388\":0.126,\"stu6389\":0.184,\"stu6390\":-0.414,\"stu6391\":0.039,\"stu6392\":-0.072,\"stu6394\":0.093,\"stu6397\":0.085,\"stu6399\":-0.117,\"stu6400\":-0.034,\"stu6403\":0.169,\"stu6404\":-0.058,\"stu6410\":-0.072,\"stu6415\":-0.143,\"stu6417\":-0.034,\"stu6420\":-0.092,\"stu6423\":0.073,\"stu6425\":-0.039,\"stu6426\":-0.344,\"stu6429\":-0.075,\"stu6430\":0.199,\"stu6433\":-0.02,\"stu6468\":0.073,\"stu6469\":0.151,\"stu6471\":0.126,\"stu6472\":-0.239},")
      when '765' # initial lauw reputation from (765)
        req.body.prepend("\"initial_lauw_leniency\":{\"stu5498\":0.059,\"stu5884\":-0.009,\"stu5892\":0.096,\"stu5899\":-0.042,\"stu5900\":-0.105,\"stu5918\":-0.116,\"stu5920\":-0.25,\"stu5931\":-0.045,\"stu5933\":-0.365,\"stu6361\":-0.116,\"stu6362\":-0.006,\"stu6364\":-0.062,\"stu6368\":0.053,\"stu6370\":0.068,\"stu6371\":0.081,\"stu6372\":-0.492,\"stu6373\":0.063,\"stu6374\":0.075,\"stu6375\":0.107,\"stu6378\":-0.008,\"stu6380\":0.122,\"stu6381\":-0.014,\"stu6382\":0.045,\"stu6385\":-0.008,\"stu6387\":0.077,\"stu6388\":0.016,\"stu6390\":0.023,\"stu6391\":-0.127,\"stu6392\":-0.042,\"stu6397\":0.049,\"stu6399\":0.096,\"stu6400\":-0.043,\"stu6403\":-0.045,\"stu6404\":-0.006,\"stu6405\":0.105,\"stu6410\":0.03,\"stu6414\":0.023,\"stu6415\":0.122,\"stu6417\":0.081,\"stu6420\":0.03,\"stu6423\":0.077,\"stu6425\":0.076,\"stu6426\":0.131,\"stu6429\":-0.043,\"stu6430\":0.03,\"stu6433\":0.03,\"stu6468\":0.023,\"stu6469\":-0.009,\"stu6471\":-0.009,\"stu6472\":0.139},")
      # 754 round 1
      when '1'
        req.body.prepend("\"initial_lauw_leniency\":{\"stu5498\":-0.018,\"stu5884\":0.029,\"stu5892\":-0.013,\"stu5899\":-0.126,\"stu5900\":-0.018,\"stu5913\":0.077,\"stu5918\":0.088,\"stu5920\":-0.013,\"stu5931\":0.032,\"stu5933\":-0.083,\"stu6361\":-0.003,\"stu6362\":-0.123,\"stu6364\":-0.003,\"stu6368\":-0.129,\"stu6370\":-0.013,\"stu6371\":0.023,\"stu6372\":-0.15,\"stu6373\":0.116,\"stu6374\":0.066,\"stu6375\":0.006,\"stu6376\":0.027,\"stu6378\":0.092,\"stu6380\":-0.018,\"stu6381\":0.077,\"stu6382\":-0.135,\"stu6385\":0.02,\"stu6387\":0.017,\"stu6388\":-0.125,\"stu6389\":-0.237,\"stu6390\":0.017,\"stu6391\":-0.014,\"stu6392\":-0.09,\"stu6394\":0.048,\"stu6397\":0.023,\"stu6399\":-0.15,\"stu6400\":0.01,\"stu6403\":0.077,\"stu6404\":-0.013,\"stu6405\":-0.003,\"stu6410\":-0.078,\"stu6414\":-0.076,\"stu6415\":0.147,\"stu6417\":0.029,\"stu6420\":0.01,\"stu6423\":-0.053,\"stu6425\":-0.175,\"stu6426\":-0.09,\"stu6429\":0.043,\"stu6430\":0.09,\"stu6431\":0.097,\"stu6433\":-0.009,\"stu6468\":-0.013,\"stu6469\":-0.436,\"stu6471\":0.056,\"stu6472\":0.029},")
      # 764 round 1
      when '2'
        req.body.prepend("\"initial_lauw_leniency\":{\"stu5498\":-0.616,\"stu5884\":0.142,\"stu5892\":-0.01,\"stu5899\":-0.01,\"stu5900\":0.142,\"stu5913\":0.083,\"stu5918\":-0.136,\"stu5920\":-0.134,\"stu5931\":-0.012,\"stu5933\":-0.376,\"stu6361\":-0.391,\"stu6362\":0.142,\"stu6364\":-0.1,\"stu6368\":-0.273,\"stu6370\":0.14,\"stu6371\":0.172,\"stu6372\":0.224,\"stu6373\":-1.0,\"stu6374\":-0.48,\"stu6375\":0.015,\"stu6376\":-1.0,\"stu6378\":0.181,\"stu6380\":0.192,\"stu6381\":0.076,\"stu6382\":0.037,\"stu6385\":-0.029,\"stu6387\":0.151,\"stu6388\":-0.162,\"stu6389\":-0.136,\"stu6390\":0.083,\"stu6391\":0.054,\"stu6392\":-0.001,\"stu6397\":0.06,\"stu6399\":-0.035,\"stu6400\":0.123,\"stu6403\":0.255,\"stu6404\":-0.102,\"stu6405\":-0.188,\"stu6410\":0.099,\"stu6414\":0.176,\"stu6415\":0.192,\"stu6417\":0.06,\"stu6420\":0.046,\"stu6423\":0.111,\"stu6425\":0.015,\"stu6426\":-0.136,\"stu6429\":-0.082,\"stu6430\":-0.261,\"stu6433\":0.063,\"stu6468\":-0.363,\"stu6469\":-0.012,\"stu6471\":-0.013,\"stu6472\":-0.316},")
      # 765 round 1
      when '3'
        req.body.prepend("\"initial_lauw_leniency\":{\"stu5498\":-0.124,\"stu5884\":-0.036,\"stu5892\":0.085,\"stu5899\":-0.003,\"stu5900\":-0.072,\"stu5913\":0.086,\"stu5918\":0.034,\"stu5920\":0.091,\"stu5931\":0.086,\"stu5933\":-0.401,\"stu6361\":0.034,\"stu6362\":0.086,\"stu6364\":0.019,\"stu6368\":-0.031,\"stu6370\":-0.013,\"stu6371\":0.091,\"stu6372\":-0.013,\"stu6373\":0.143,\"stu6374\":-0.132,\"stu6375\":-1.0,\"stu6378\":0.034,\"stu6380\":0.19,\"stu6381\":0.077,\"stu6382\":0.135,\"stu6385\":0.091,\"stu6387\":0.028,\"stu6388\":-0.016,\"stu6389\":-0.013,\"stu6390\":0.063,\"stu6391\":0.109,\"stu6392\":-0.003,\"stu6394\":0.114,\"stu6397\":0.11,\"stu6399\":0.055,\"stu6400\":-0.624,\"stu6403\":0.169,\"stu6405\":0.082,\"stu6410\":0.115,\"stu6414\":0.114,\"stu6415\":0.141,\"stu6417\":0.003,\"stu6420\":0.193,\"stu6423\":-0.072,\"stu6425\":-0.062,\"stu6426\":0.025,\"stu6429\":0.137,\"stu6430\":-0.524,\"stu6433\":0.086,\"stu6468\":0.091,\"stu6469\":0.058,\"stu6471\":-0.036,\"stu6472\":-0.025},")
      # 772 round 1
      when '4'
        req.body.prepend("\"initial_lauw_leniency\":{\"stu5498\":0.117,\"stu5884\":-1.0,\"stu5892\":-0.306,\"stu5899\":-0.051,\"stu5900\":-0.493,\"stu5913\":-1.0,\"stu5918\":-0.126,\"stu5920\":0.129,\"stu5931\":-0.341,\"stu5933\":-0.045,\"stu6361\":-1.0,\"stu6362\":-1.0,\"stu6364\":-0.014,\"stu6368\":-0.003,\"stu6370\":-0.192,\"stu6371\":-0.568,\"stu6372\":-0.003,\"stu6373\":-0.183,\"stu6374\":-0.014,\"stu6375\":0.148,\"stu6378\":0.113,\"stu6380\":0.129,\"stu6381\":0.032,\"stu6382\":-0.079,\"stu6385\":0.833,\"stu6387\":0.074,\"stu6388\":-0.162,\"stu6389\":0.04,\"stu6390\":-0.183,\"stu6391\":0.197,\"stu6392\":-0.199,\"stu6394\":-1.0,\"stu6397\":0.091,\"stu6399\":0.252,\"stu6403\":0.151,\"stu6404\":0.818,\"stu6405\":-0.177,\"stu6410\":-0.274,\"stu6414\":-0.079,\"stu6415\":0.818,\"stu6417\":0.04,\"stu6420\":-0.079,\"stu6423\":-0.015,\"stu6425\":-1.0,\"stu6426\":0.04,\"stu6429\":0.071,\"stu6430\":-0.126,\"stu6433\":-0.177,\"stu6468\":0.08,\"stu6469\":-0.331,\"stu6471\":0.091,\"stu6472\":-1.0},")
      # 754 round2
      when '5'
        req.body.prepend("\"initial_lauw_leniency\":{\"stu5498\":-0.143,\"stu5884\":0.025,\"stu5892\":-0.111,\"stu5899\":-0.039,\"stu5900\":0.068,\"stu5913\":-0.013,\"stu5918\":0.007,\"stu5920\":-0.07,\"stu5931\":-0.007,\"stu5933\":-0.056,\"stu6361\":-0.047,\"stu6362\":-0.204,\"stu6364\":0.01,\"stu6368\":0.026,\"stu6370\":0.004,\"stu6371\":-0.039,\"stu6372\":-0.027,\"stu6373\":0.043,\"stu6374\":0.027,\"stu6375\":-0.056,\"stu6376\":0.028,\"stu6378\":0.028,\"stu6380\":0.038,\"stu6381\":0.034,\"stu6382\":-0.036,\"stu6385\":-0.027,\"stu6387\":-0.095,\"stu6388\":0.043,\"stu6389\":-0.041,\"stu6390\":-0.137,\"stu6391\":-0.067,\"stu6392\":-0.02,\"stu6394\":0.087,\"stu6397\":-0.023,\"stu6399\":-0.045,\"stu6400\":-0.141,\"stu6403\":0.029,\"stu6404\":0.021,\"stu6405\":-0.007,\"stu6410\":-0.171,\"stu6414\":-0.06,\"stu6415\":0.058,\"stu6417\":0.025,\"stu6420\":-0.006,\"stu6423\":-0.164,\"stu6425\":0.021,\"stu6426\":-0.02,\"stu6429\":-0.004,\"stu6430\":0.014,\"stu6433\":-0.003,\"stu6468\":0.053,\"stu6469\":-0.229,\"stu6471\":0.045,\"stu6472\":0.025},")
      # 764 round2
      when '6'
        req.body.prepend("\"initial_lauw_leniency\":{\"stu5498\":-0.269,\"stu5884\":-0.034,\"stu5892\":0.003,\"stu5899\":-0.039,\"stu5900\":0.18,\"stu5913\":-0.001,\"stu5918\":-0.472,\"stu5920\":0.011,\"stu5931\":0.009,\"stu5933\":0.076,\"stu6361\":-0.247,\"stu6362\":-0.081,\"stu6364\":-0.214,\"stu6368\":0.151,\"stu6370\":0.121,\"stu6371\":0.003,\"stu6372\":-0.093,\"stu6373\":0.003,\"stu6374\":-0.487,\"stu6375\":-0.143,\"stu6376\":-0.034,\"stu6378\":-0.072,\"stu6380\":0.086,\"stu6381\":-0.026,\"stu6382\":0.049,\"stu6385\":0.056,\"stu6387\":0.046,\"stu6388\":0.126,\"stu6389\":0.184,\"stu6390\":-0.414,\"stu6391\":0.039,\"stu6392\":-0.072,\"stu6394\":0.093,\"stu6397\":0.085,\"stu6399\":-0.117,\"stu6400\":-0.034,\"stu6403\":0.169,\"stu6404\":-0.058,\"stu6410\":-0.072,\"stu6415\":-0.143,\"stu6417\":-0.034,\"stu6420\":-0.092,\"stu6423\":0.073,\"stu6425\":-0.039,\"stu6426\":-0.344,\"stu6429\":-0.075,\"stu6430\":0.199,\"stu6433\":-0.02,\"stu6468\":0.073,\"stu6469\":0.151,\"stu6471\":0.126,\"stu6472\":-0.239},")
      end
    elsif params[:checkbox][:quiz] == 'Add quiz scores'
      @@additional_info = 'add quiz scores'
      quiz_str = json_generator(params[:assignment_id].to_i, params[:another_assignment_id].to_i, params[:round_num].to_i, 'quiz scores').to_json
      quiz_str[0] = ''
      quiz_str.prepend('"quiz_scores":{')
      quiz_str += ','
      quiz_str = quiz_str.gsub('"N/A"', '20.0')
      req.body.prepend(quiz_str)
    else
      @@additional_info = ''
    end

    # Eg.
    # "{"initial_hamer_reputation": {"stu1": 0.90, "stu2":0.88, "stu3":0.93, "stu4":0.8, "stu5":0.93, "stu8":0.93},  #optional
    # "initial_lauw_leniency": {"stu1": 1.90, "stu2":0.98, "stu3":1.12, "stu4":0.94, "stu5":1.24, "stu8":1.18},  #optional
    # "expert_grades": {"submission1": 90, "submission2":88, "submission3":93},  #optional
    # "quiz_scores" : {"submission1" : {"stu1":100, "stu3":80}, "submission2":{"stu2":40, "stu1":60}}, #optional
    # "submission1": {"stu1":91, "stu3":99},"submission2": {"stu5":92, "stu8":90},"submission3": {"stu2":91, "stu4":88}}"
    req.body.prepend("{")
    @@request_body = req.body
    puts 'This is the request prior to encryption: ' + req.body
    puts
    # Encryption
    # AES symmetric algorithm encrypts raw data
    aes_encrypted_request_data = aes_encrypt(req.body)
    req.body = aes_encrypted_request_data[0]
    # RSA asymmetric algorithm encrypts keys of AES
    encrypted_key = rsa_public_key1(aes_encrypted_request_data[1])
    encrypted_vi = rsa_public_key1(aes_encrypted_request_data[2])
    # fixed length 350
    req.body.prepend('", "data":"')
    req.body.prepend(encrypted_vi)
    req.body.prepend(encrypted_key)
    # request body should be in JSON format.
    req.body.prepend('{"keys":"')
    req.body << '"}'
    req.body.gsub!(/\n/, '\\n')
    response = Net::HTTP.new('peerlogic.csc.ncsu.edu').start {|http| http.request(req) }
    # RSA asymmetric algorithm decrypts keys of AES
    # Decryption
    response.body = JSON.parse(response.body)
    key = rsa_private_key2(response.body["keys"][0, 350])
    vi = rsa_private_key2(response.body["keys"][350, 350])
    # AES symmetric algorithm decrypts data
    aes_encrypted_response_data = response.body["data"]
    response.body = aes_decrypt(aes_encrypted_response_data, key, vi)

    puts "Response #{response.code} #{response.message}:
          #{response.body}"
    puts
    @@response = response
    @@response_body = response.body

    JSON.parse(response.body.to_s).each do |alg, list|
      next unless alg == "Hamer" || alg == "Lauw"
      list.each do |id, rep|
        Participant.find_by_user_id(id).update(alg.to_sym => rep) unless /leniency/ =~ id.to_s
      end
    end

    redirect_to action: 'client'
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
