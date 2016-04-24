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

	def action_allowed?
	  ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
	end

	# normal db query, return peer review grades
	def db_query(assignment_id, another_assignment_id = 0, round_num, hasTopic)
=begin
	  query="SELECT U.id, RM.reviewee_id as submission_id, "+
		    "sum(A.answer * Q.weight) / sum(QN.max_question_score * Q.weight) * 100 as total_score "+
			# new way to calculate the grades of coding artifacts
			#"100 - SUM((QN.max_question_score-A.answer) * Q.weight) AS total_score "+
			"from answers A  "+
			"inner join questions Q on A.question_id = Q.id "+
			"inner join questionnaires QN on Q.questionnaire_id = QN.id "+
			"inner join responses R on A.response_id = R.id "+
			"inner join response_maps RM on R.map_id = RM.id "+
			"inner join participants P on P.id = RM.reviewer_id "+
			"inner join users U on U.id = P.user_id "+
			"inner join teams T on T.id = RM.reviewee_id "
			query += "inner join signed_up_teams SU_team on SU_team.team_id = T.id " if hasTopic == true
			query += "where RM.type='ReviewResponseMap' "+
			"and RM.reviewed_object_id = "+  assignment_id.to_s + " " +
			"and A.answer is not null "+
			"and Q.type ='Criterion' "+
			#If one assignment is varying rubric by round (724, 733, 736) or 2-round peer review with (735), 
			#the round field in response records corresponding to ReviewResponseMap will be 1 or 2, will not be null.
			"and R.round = 2 "  
			query+="and SU_team.is_waitlisted = 0 " if hasTopic == true
			query+="group by RM.id "+
			"order by RM.reviewee_id"

        result = ActiveRecord::Base.connection.select_all(query)
=end
		raw_data_array = Array.new
		assignment_ids = Array.new
		assignment_ids << assignment_id
		assignment_ids << another_assignment_id unless another_assignment_id == 0
		ReviewResponseMap.where(['reviewed_object_id in (?)', assignment_ids]).each do |response_map|
			reviewer = response_map.reviewer.user
			team = AssignmentTeam.find(response_map.reviewee_id)
			topic_condition = ((hasTopic and SignedUpTeam.where(team_id: team.id).first.is_waitlisted == false) or !hasTopic)
			last_valid_response = response_map.response.select{|r| r.round == round_num}.sort.last
			valid_response = [last_valid_response] unless last_valid_response.nil?
			if topic_condition == true and !valid_response.nil? and !valid_response.empty?
				valid_response.each do |response|
					answers = Answer.where(response_id: response.id)
					max_question_score = answers.first.question.questionnaire.max_question_score
					temp_sum = 0
					weight_sum = 0
					valid_answer = answers.select{|a| a.question.type == 'Criterion' and !a.answer.nil?}
					unless valid_answer.empty?
						valid_answer.each do |answer|
							temp_sum += answer.answer * answer.question.weight
							weight_sum += answer.question.weight
						end

						peer_review_grade = 100.0 * temp_sum / (weight_sum * max_question_score)
						raw_data_array << [reviewer.id, team.id, peer_review_grade.round(4)]
					end
				end
			end
		end
		raw_data_array
	end

	# special db query, return quiz scores
	def db_query_with_quiz_score(assignment_id, another_assignment_id = 0)
		raw_data_array = Array.new
		assignment_ids = Array.new
		assignment_ids << assignment_id
		assignment_ids << another_assignment_id unless another_assignment_id == 0
		teams = AssignmentTeam.where(['parent_id in (?)', assignment_ids])
		team_ids = Array.new
		teams.each{|team| team_ids << team.id }
		quiz_questionnnaires = QuizQuestionnaire.where(['instructor_id in (?)', team_ids])
		quiz_questionnnaire_ids = Array.new
		quiz_questionnnaires.each{|questionnaire| quiz_questionnnaire_ids << questionnaire.id }
		QuizResponseMap.where(['reviewed_object_id in (?)', quiz_questionnnaire_ids]).each do |response_map|
			quiz_score = response_map.quiz_score
			participant = Participant.find(response_map.reviewer_id)
			raw_data_array << [participant.user_id, response_map.reviewee_id, quiz_score]
		end
		raw_data_array
	end

	def json_generator(assignment_id, another_assignment_id = 0, round_num = 2, type = 'peer review grades')
		assignment = Assignment.find(assignment_id)
		has_topic = !SignUpTopic.where(assignment_id: assignment_id).empty?
		
		if type == 'peer review grades'
			@results = db_query(assignment.id, another_assignment_id, round_num, has_topic)
		elsif type == 'quiz scores'
			@results = db_query_with_quiz_score(assignment.id, another_assignment_id)
		end
		request_body = Hash.new
		inner_msg = Hash.new
		@results.each_with_index do |record, index|
			if !request_body.has_key?('submission' + record[1].to_s)
				request_body['submission' + record[1].to_s] = Hash.new
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
	end

	def send_post_request
		# https://www.socialtext.net/open/very_simple_rest_in_ruby_part_3_post_to_create_a_new_workspace
		req = Net::HTTP::Post.new('/reputation/calculations/reputation_algorithms', initheader = {'Content-Type' =>'application/json', 'charset' => 'utf-8'})
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
				else   # expert grades of Wiki 1a and 1b (724, 733)
		 			req.body.prepend("\"expert_grades\": {\"submission23967\":93, \"submission23969\":89, \"submission23971\":95, \"submission23972\":86, \"submission23973\":91, \"submission23975\":94, \"submission23979\":90, \"submission23980\":94, \"submission23981\":87, \"submission23982\":79, \"submission23983\":91, \"submission23986\":92, \"submission23987\":91, \"submission23988\":93, \"submission23991\":98, \"submission23992\":91, \"submission23994\":87, \"submission23995\":93, \"submission23998\":92, \"submission23999\":87, \"submission24000\":93, \"submission24001\":93, \"submission24006\":96, \"submission24007\":87, \"submission24008\":92, \"submission24009\":92, \"submission24010\":93, \"submission24012\":94, \"submission24013\":96, \"submission24016\":91, \"submission24018\":93, \"submission24024\":96, \"submission24028\":88, \"submission24031\":94, \"submission24040\":93, \"submission24043\":95, \"submission24044\":91, \"submission24046\":95, \"submission24051\":92, \"submission24100\":90, \"submission24079\":92, \"submission24298\":86, \"submission24545\":92, \"submission24082\":96, \"submission24080\":86, \"submission24284\":92, \"submission24534\":93, \"submission24285\":94, \"submission24297\":91},")
		 		end
			when '735' # expert grades of program 1 (735)
				req.body.prepend("\"expert_grades\": {\"submission24083\":96.084,\"submission24085\":88.811,\"submission24086\":100,\"submission24087\":100,\"submission24088\":92.657,\"submission24091\":96.783,\"submission24092\":90.21,\"submission24093\":100,\"submission24097\":90.909,\"submission24098\":98.601,\"submission24101\":99.301,\"submission24278\":98.601,\"submission24279\":72.727,\"submission24281\":54.476,\"submission24289\":94.406,\"submission24291\":99.301,\"submission24293\":93.706,\"submission24296\":98.601,\"submission24302\":83.217,\"submission24303\":91.329,\"submission24305\":100,\"submission24307\":100,\"submission24308\":100,\"submission24311\":95.804,\"submission24313\":91.049,\"submission24314\":100,\"submission24315\":97.483,\"submission24316\":91.608,\"submission24317\":98.182,\"submission24320\":90.21,\"submission24321\":90.21,\"submission24322\":98.601},")
			when '754' # expert grades of Wiki contribution (754)
				req.body.prepend("\"expert_grades\": {\"submission25030\":95,\"submission25031\":92,\"submission25033\":88,\"submission25034\":98,\"submission25035\":100,\"submission25037\":95,\"submission25038\":95,\"submission25039\":93,\"submission25040\":96,\"submission25041\":90,\"submission25042\":100,\"submission25046\":95,\"submission25049\":90,\"submission25050\":88,\"submission25053\":91,\"submission25054\":96,\"submission25055\":94,\"submission25059\":96,\"submission25071\":85,\"submission25082\":100,\"submission25086\":95,\"submission25097\":90,\"submission25098\":85,\"submission25102\":97,\"submission25103\":94,\"submission25105\":98,\"submission25114\":95,\"submission25115\":94},")
			when '756' # expert grades of Wikipedia contribution (756)
				req.body.prepend("\"expert_grades\": {\"submission25107\":87,\"submission25109\":93},")
			end
		elsif params[:checkbox][:hamer] == 'Add initial Hamer reputation values'
			@@additional_info = 'add initial hamer reputation values'
			case params[:hamer_assignment_id]
			when '724' # initial hamer reputation from Wiki 1a (724)
				if params[:another_hamer_assignment_id].to_i == 0
					req.body.prepend("\"initial_hamer_reputation\":{\"stu5787\":1.726,\"stu5790\":3.275,\"stu5791\":1.059,\"stu5796\":0.461,\"stu5797\":5.593,\"stu5800\":3.116,\"stu5807\":2.776,\"stu5808\":4.077,\"stu5810\":0.74,\"stu5815\":2.301,\"stu5818\":1.186,\"stu5825\":2.686,\"stu5826\":2.053,\"stu5827\":0.447,\"stu5828\":0.521,\"stu5829\":3.236,\"stu5835\":1.13,\"stu5837\":0.414,\"stu5839\":0.531,\"stu5843\":2.217,\"stu5846\":1.337,\"stu5849\":0.786,\"stu5850\":2.023,\"stu5855\":0.26,\"stu5856\":0.481,\"stu5857\":2.198,\"stu5859\":2.212,\"stu5860\":0.811,\"stu5862\":0.632,\"stu5864\":1.098,\"stu5866\":0.361,\"stu5867\":5.945,\"stu5870\":3.368,\"stu5874\":1.749,\"stu5880\":0.56},")
				elsif params[:another_hamer_assignment_id].to_i == 733  # initial hamer reputation of Wiki 1a and 1b (724, 733)
					req.body.prepend("\"initial_hamer_reputation\":{\"stu5687\":1.251,\"stu5787\":2.14,\"stu5790\":3.421,\"stu5791\":1.462,\"stu5795\":1.107,\"stu5796\":0.635,\"stu5797\":2.15,\"stu5800\":1.253,\"stu5801\":2.653,\"stu5804\":2.15,\"stu5806\":0.799,\"stu5807\":2.086,\"stu5808\":4.218,\"stu5810\":1.021,\"stu5811\":3.76,\"stu5814\":0.919,\"stu5815\":2.497,\"stu5818\":0.311,\"stu5820\":2.47,\"stu5822\":2.302,\"stu5824\":2.103,\"stu5825\":2.85,\"stu5826\":2.287,\"stu5827\":0.432,\"stu5828\":0.719,\"stu5829\":3.383,\"stu5830\":0.881,\"stu5832\":2.544,\"stu5835\":1.56,\"stu5837\":0.571,\"stu5839\":0.733,\"stu5840\":0.984,\"stu5841\":0.5,\"stu5843\":2.424,\"stu5846\":1.612,\"stu5848\":0.747,\"stu5849\":0.295,\"stu5850\":2.263,\"stu5855\":0.33,\"stu5856\":0.664,\"stu5857\":2.407,\"stu5859\":2.419,\"stu5860\":0.619,\"stu5862\":0.873,\"stu5863\":0.714,\"stu5864\":1.515,\"stu5866\":0.499,\"stu5867\":2.191,\"stu5868\":1.986,\"stu5869\":0.746,\"stu5870\":0.249,\"stu5871\":2.135,\"stu5873\":0.521,\"stu5874\":0.911,\"stu5875\":1.949,\"stu5876\":1.313,\"stu5880\":0.773},")
				end
			when '735' # initial hamer reputation from program 1 (735)
				req.body.prepend("\"initial_hamer_reputation\":{\"stu4381\":2.649,\"stu5415\":3.022,\"stu5687\":3.578,\"stu5787\":3.142,\"stu5788\":2.424,\"stu5789\":0.134,\"stu5790\":2.885,\"stu5792\":2.27,\"stu5793\":2.317,\"stu5794\":2.219,\"stu5795\":1.232,\"stu5796\":0.832,\"stu5797\":2.946,\"stu5798\":0.225,\"stu5799\":5.365,\"stu5800\":2.749,\"stu5801\":4.161,\"stu5802\":4.78,\"stu5803\":0.366,\"stu5804\":0.262,\"stu5805\":3.016,\"stu5806\":0.561,\"stu5807\":3.028,\"stu5808\":3.573,\"stu5810\":3.664,\"stu5812\":2.638,\"stu5813\":2.621,\"stu5814\":3.035,\"stu5815\":2.985,\"stu5816\":0.11,\"stu5817\":2.16,\"stu5818\":0.448,\"stu5821\":0.294,\"stu5822\":1.874,\"stu5823\":3.339,\"stu5824\":3.597,\"stu5825\":4.033,\"stu5826\":2.962,\"stu5827\":1.49,\"stu5828\":3.208,\"stu5830\":1.211,\"stu5832\":0.406,\"stu5833\":3.04,\"stu5836\":3.396,\"stu5838\":4.519,\"stu5839\":2.974,\"stu5840\":1.952,\"stu5843\":3.515,\"stu5844\":0.627,\"stu5845\":2.355,\"stu5846\":3.604,\"stu5847\":3.847,\"stu5848\":1.488,\"stu5849\":2.078,\"stu5850\":2.957,\"stu5851\":2.774,\"stu5852\":2.345,\"stu5853\":1.717,\"stu5854\":2.275,\"stu5855\":2.216,\"stu5856\":1.4,\"stu5857\":3.463,\"stu5858\":3.132,\"stu5859\":3.327,\"stu5860\":0.965,\"stu5861\":1.683,\"stu5862\":1.646,\"stu5863\":0.457,\"stu5864\":3.901,\"stu5866\":2.402,\"stu5867\":1.495,\"stu5868\":0.198,\"stu5869\":1.434,\"stu5870\":0.43,\"stu5871\":0.654,\"stu5872\":0.854,\"stu5873\":2.645,\"stu5874\":1.988,\"stu5875\":0.089,\"stu5876\":3.438,\"stu5878\":3.763,\"stu5880\":2.444,\"stu5881\":0.316},")
			when '756' # initial hamer reputation from Calibration assignment (756)
				req.body.prepend("\"initial_hamer_reputation\":{\"stu2\":2.251,\"stu5498\":3.607,\"stu5884\":5.7,\"stu5892\":1.566,\"stu5899\":2.312,\"stu5900\":2.696,\"stu5913\":3.11,\"stu5918\":0.605,\"stu5920\":2.361,\"stu5931\":0.475,\"stu5933\":0.979,\"stu6360\":0.277,\"stu6361\":1.566,\"stu6362\":0.633,\"stu6364\":0.802,\"stu6368\":3.11,\"stu6370\":3.785,\"stu6371\":1.228,\"stu6372\":0.724,\"stu6373\":1.815,\"stu6374\":0.979,\"stu6375\":1.927,\"stu6376\":0.248,\"stu6378\":2.581,\"stu6380\":5.7,\"stu6381\":1.099,\"stu6382\":0.956,\"stu6385\":2.361,\"stu6387\":0.928,\"stu6389\":1.099,\"stu6390\":2.361,\"stu6391\":0.499,\"stu6392\":0.192,\"stu6397\":1.927,\"stu6399\":2.973,\"stu6400\":1.228,\"stu6403\":0.286,\"stu6404\":1.053,\"stu6410\":0.928,\"stu6414\":2.624,\"stu6415\":0.564,\"stu6417\":3.607,\"stu6420\":1.347,\"stu6423\":1.347,\"stu6425\":2.696,\"stu6426\":3.785,\"stu6429\":1.491,\"stu6430\":0.876,\"stu6433\":1.228,\"stu6468\":3.377,\"stu6469\":0.803,\"stu6471\":0.428,\"stu6472\":0.499},")
			end
		elsif params[:checkbox][:lauw] == 'Add initial Lauw reputation values'
			@@additional_info = 'add initial lauw reputation values'
			case params[:lauw_assignment_id]
			when '724' # initial lauw reputation from Wiki 1a (724)
				if params[:another_lauw_assignment_id].to_i == 0
					# do nothing now
				elsif params[:another_lauw_assignment_id].to_i == 733  # initial lauw reputation of Wiki 1a and 1b (724, 733)
					req.body.prepend("\"initial_lauw_leniency\":{\"stu5687\":-0.018,\"stu5787\":-0.025,\"stu5790\":-0.004,\"stu5791\":0.05,\"stu5795\":-0.061,\"stu5796\":0.009,\"stu5797\":0.113,\"stu5800\":0.127,\"stu5801\":0.07,\"stu5804\":-0.131,\"stu5806\":0.084,\"stu5807\":-0.099,\"stu5808\":-0.002,\"stu5810\":-0.006,\"stu5811\":-0.014,\"stu5814\":0.04,\"stu5815\":0.03,\"stu5818\":-0.424,\"stu5820\":0.069,\"stu5822\":0.09,\"stu5824\":-0.131,\"stu5825\":0.042,\"stu5826\":0.076,\"stu5827\":0.113,\"stu5828\":-0.165,\"stu5829\":-0.04,\"stu5830\":0.09,\"stu5832\":0.08,\"stu5835\":0.07,\"stu5837\":0.035,\"stu5839\":-0.144,\"stu5840\":0.003,\"stu5841\":-0.343,\"stu5843\":-0.053,\"stu5846\":-0.031,\"stu5848\":0.14,\"stu5849\":-0.391,\"stu5850\":0.003,\"stu5855\":0.051,\"stu5856\":0.09,\"stu5857\":0.09,\"stu5859\":0.08,\"stu5860\":0.025,\"stu5862\":0.05,\"stu5863\":0.07,\"stu5864\":-0.144,\"stu5866\":-0.014,\"stu5867\":0.03,\"stu5868\":0.09,\"stu5869\":0.053,\"stu5870\":-0.087,\"stu5871\":0.1,\"stu5873\":0.051,\"stu5874\":-0.119,\"stu5875\":-0.165,\"stu5876\":0.127,\"stu5880\":0.01},")
				end
			when '735' # initial lauw reputation from program 1 (735)
				req.body.prepend("\"initial_lauw_leniency\":{\"stu4381\":-0.086,\"stu5415\":0.003,\"stu5687\":0.039,\"stu5787\":-0.029,\"stu5788\":-0.034,\"stu5789\":0.124,\"stu5790\":-0.006,\"stu5792\":-0.017,\"stu5793\":0.014,\"stu5794\":0.027,\"stu5795\":-0.001,\"stu5796\":-0.029,\"stu5797\":0.012,\"stu5798\":0.012,\"stu5799\":0.008,\"stu5800\":-0.009,\"stu5801\":0.003,\"stu5802\":0.015,\"stu5803\":-1.0,\"stu5804\":-1.0,\"stu5805\":-0.016,\"stu5806\":0.014,\"stu5807\":0.054,\"stu5808\":0.027,\"stu5810\":0.042,\"stu5812\":0.128,\"stu5813\":-0.066,\"stu5814\":0.084,\"stu5815\":-0.016,\"stu5816\":-1.0,\"stu5817\":-0.165,\"stu5818\":-0.248,\"stu5821\":-1.0,\"stu5822\":0.025,\"stu5823\":-0.076,\"stu5824\":0.054,\"stu5825\":0.018,\"stu5826\":0.0,\"stu5827\":0.014,\"stu5828\":-0.051,\"stu5830\":0.098,\"stu5832\":-0.038,\"stu5833\":0.098,\"stu5836\":0.067,\"stu5838\":-0.021,\"stu5839\":-0.068,\"stu5840\":-0.209,\"stu5843\":-0.022,\"stu5844\":-0.138,\"stu5845\":-0.072,\"stu5846\":-0.05,\"stu5847\":-0.011,\"stu5848\":0.014,\"stu5849\":0.098,\"stu5850\":-0.017,\"stu5851\":0.014,\"stu5852\":0.006,\"stu5853\":0.084,\"stu5854\":-0.242,\"stu5855\":0.023,\"stu5856\":0.018,\"stu5857\":-0.048,\"stu5858\":-0.066,\"stu5859\":0.025,\"stu5860\":-0.45,\"stu5861\":-0.04,\"stu5862\":0.033,\"stu5863\":0.0,\"stu5864\":-0.019,\"stu5866\":-0.001,\"stu5867\":-0.047,\"stu5868\":-0.303,\"stu5869\":-0.111,\"stu5870\":0.039,\"stu5871\":0.023,\"stu5872\":0.098,\"stu5873\":0.098,\"stu5874\":-0.034,\"stu5875\":-0.068,\"stu5876\":0.014,\"stu5878\":-0.05,\"stu5880\":0.09,\"stu5881\":0.069},")
			when '756' # initial lauw reputation from Calibration assignment (756)
				req.body.prepend("\"initial_lauw_leniency\":{\"stu2\":0.884,\"stu5498\":0.962,\"stu5884\":0.996,\"stu5892\":0.838,\"stu5899\":0.838,\"stu5900\":0.884,\"stu5913\":0.927,\"stu5918\":0.996,\"stu5920\":0.838,\"stu5931\":0.927,\"stu5933\":0.967,\"stu6360\":0.732,\"stu6361\":0.838,\"stu6362\":0.532,\"stu6364\":0.605,\"stu6368\":0.927,\"stu6370\":0.967,\"stu6371\":0.927,\"stu6372\":0.927,\"stu6373\":0.787,\"stu6374\":0.967,\"stu6375\":0.996,\"stu6376\":0.927,\"stu6378\":0.967,\"stu6380\":0.996,\"stu6381\":0.884,\"stu6382\":0.838,\"stu6385\":0.838,\"stu6387\":0.927,\"stu6389\":0.884,\"stu6390\":0.838,\"stu6391\":0.732,\"stu6392\":0.605,\"stu6397\":0.996,\"stu6399\":0.927,\"stu6400\":0.927,\"stu6403\":0.927,\"stu6404\":0.671,\"stu6410\":0.927,\"stu6414\":0.884,\"stu6415\":0.532,\"stu6417\":0.956,\"stu6420\":0.695,\"stu6423\":0.996,\"stu6425\":0.884,\"stu6426\":0.967,\"stu6429\":0.787,\"stu6430\":0.671,\"stu6433\":0.787,\"stu6468\":0.967,\"stu6469\":0.605,\"stu6471\":0.838,\"stu6472\":0.732},")
			end
		elsif params[:checkbox][:quiz] == 'Add quiz scores'
			@@additional_info = 'add quiz scores'
			quiz_str = json_generator(params[:assignment_id].to_i, params[:another_assignment_id].to_i, params[:round_num].to_i, 'quiz scores').to_json
			quiz_str[0] = ''
			quiz_str.prepend('"quiz_scores":{')
			quiz_str += ','
			quiz_str = quiz_str.gsub('"N/A"','20.0')
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
		response = Net::HTTP.new('prevdata.csc.ncsu.edu').start {|http| http.request(req)}
		# RSA asymmetric algorithm decrypts keys of AES
	# Decryption
		response.body = JSON.parse(response.body)
		key = rsa_private_key2(response.body["keys"][0, 350])
		vi = rsa_private_key2(response.body["keys"][350,350])
		# AES symmetric algorithm decrypts data
		aes_encrypted_response_data = response.body["data"]
		response.body = aes_decrypt(aes_encrypted_response_data, key, vi)

		puts "Response #{response.code} #{response.message}:
          #{response.body}"
        puts
        @@response_body = response.body



		JSON.parse(response.body.to_s).each do |alg, list|
			unless list.nil?
				list.each do |id, rep|
					unless /leniency/ =~ id.to_s
						Participant.find_by_user_id(id).update_reputation(alg, rep).save!
					end
				end
			end
		end

		redirect_to action: 'client'
	end


	def rsa_public_key1(data)
		public_key_file = 'public1.pem'
		public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
		encrypted_string = Base64.encode64(public_key.public_encrypt(data))

		return encrypted_string
	end

	def rsa_private_key2(cipertext)
		private_key_file = 'private2.pem'
		password = "ZXhwZXJ0aXph\n"
		encrypted_string = cipertext
		private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file),Base64.decode64(password))
		string = private_key.private_decrypt(Base64.decode64(encrypted_string))

		return string
	end

	def aes_encrypt(data)
		cipher = OpenSSL::Cipher::AES.new(256, :CBC)
		cipher.encrypt
		key = cipher.random_key
		iv = cipher.random_iv
		cipertext = Base64.encode64(cipher.update(data) + cipher.final)
		return cipertext, key, iv
	end

	def aes_decrypt(cipertext, key, iv)
		decipher = OpenSSL::Cipher::AES.new(256, :CBC)
		decipher.decrypt
		decipher.key = key
		decipher.iv = iv
		plain = decipher.update(Base64.decode64(cipertext)) + decipher.final
		return plain
	end
end