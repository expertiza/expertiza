require 'json'
require 'uri'
require 'net/http'

class ReputationWebServiceController < ApplicationController

	@@response_body = ''

	def action_allowed?
	  ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
	end

	def db_query(assignment_id, hasTopic)
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
		ReviewResponseMap.where(reviewed_object_id: assignment_id).each do |response_map|
			reviewer = response_map.reviewer.user
			team = Team.find(response_map.reviewee_id)
			topic_condition = ((hasTopic and SignedUpTeam.where(team_id: team.id).first.is_waitlisted == false) or !hasTopic)
			last_valid_response = response_map.response.select{|r| r.round == 2}.sort.last
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

	def json_generator(assignment_id)
		assignment = Assignment.find(assignment_id)
		has_topic = !SignUpTopic.where(assignment_id: assignment_id).empty?
		@results = db_query(assignment, has_topic)
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
		@result = @@response_body
	end

	def send_post_request
		# https://www.socialtext.net/open/very_simple_rest_in_ruby_part_3_post_to_create_a_new_workspace
		# uri = URI.parse('http://152.7.99.160:3000//calculations/reputation_algorithms')
		req = Net::HTTP::Post.new('/calculations/reputation_algorithms', initheader = {'Content-Type' =>'application/json'})
		req.body = json_generator(params[:assignment_id] ||= 724).to_json
		req.body[0] = '' # remove the first '{'
		# expert grades of Wiki 1a (724)
		# req.body.prepend("\"expert_grades\": {\"submission23967\":93,\"submission23969\":89,\"submission23971\":95,\"submission23972\":86,\"submission23973\":91,\"submission23975\":94,\"submission23979\":90,\"submission23980\":94,\"submission23981\":87,\"submission23982\":79,\"submission23983\":91,\"submission23986\":92,\"submission23987\":91,\"submission23988\":93,\"submission23991\":98,\"submission23992\":91,\"submission23994\":87,\"submission23995\":93,\"submission23998\":92,\"submission23999\":87,\"submission24000\":93,\"submission24001\":93,\"submission24006\":96,\"submission24007\":87,\"submission24008\":92,\"submission24009\":92,\"submission24010\":93,\"submission24012\":94,\"submission24013\":96,\"submission24016\":91,\"submission24018\":93,\"submission24024\":96,\"submission24028\":88,\"submission24031\":94,\"submission24040\":93,\"submission24043\":95,\"submission24044\":91,\"submission24046\":95,\"submission24051\":92},")
		# expert grades of Wiki 1a and 1b (724, 733)
		# req.body.prepend("\"expert_grades\": {\"submission23967\":93, \"submission23969\":89, \"submission23971\":95, \"submission23972\":86, \"submission23973\":91, \"submission23975\":94, \"submission23979\":90, \"submission23980\":94, \"submission23981\":87, \"submission23982\":79, \"submission23983\":91, \"submission23986\":92, \"submission23987\":91, \"submission23988\":93, \"submission23991\":98, \"submission23992\":91, \"submission23994\":87, \"submission23995\":93, \"submission23998\":92, \"submission23999\":87, \"submission24000\":93, \"submission24001\":93, \"submission24006\":96, \"submission24007\":87, \"submission24008\":92, \"submission24009\":92, \"submission24010\":93, \"submission24012\":94, \"submission24013\":96, \"submission24016\":91, \"submission24018\":93, \"submission24024\":96, \"submission24028\":88, \"submission24031\":94, \"submission24040\":93, \"submission24043\":95, \"submission24044\":91, \"submission24046\":95, \"submission24051\":92, \"submission24100\":90, \"submission24079\":92, \"submission24298\":86, \"submission24545\":92, \"submission24082\":96, \"submission24080\":86, \"submission24284\":92, \"submission24534\":93, \"submission24285\":94, \"submission24297\":91},")
		# expert grades of program 1 (735)
		# req.body.prepend("\"expert_grades\": {\"submission24083\":96.084,\"submission24085\":88.811,\"submission24086\":100,\"submission24087\":100,\"submission24088\":92.657,\"submission24091\":96.783,\"submission24092\":90.21,\"submission24093\":100,\"submission24097\":90.909,\"submission24098\":98.601,\"submission24101\":99.301,\"submission24278\":98.601,\"submission24279\":72.727,\"submission24281\":54.476,\"submission24289\":94.406,\"submission24291\":99.301,\"submission24293\":93.706,\"submission24296\":98.601,\"submission24302\":83.217,\"submission24303\":91.329,\"submission24305\":100,\"submission24307\":100,\"submission24308\":100,\"submission24311\":95.804,\"submission24313\":91.049,\"submission24314\":100,\"submission24315\":97.483,\"submission24316\":91.608,\"submission24317\":98.182,\"submission24320\":90.21,\"submission24321\":90.21,\"submission24322\":98.601},")
		
		# initial hamer reputation of Wiki 1a (724)
		# req.body.prepend("\"initial_hamer_reputation\":{\"stu5787\":1.775,\"stu5790\":3.288,\"stu5791\":1.09,\"stu5796\":0.474,\"stu5797\":5.605,\"stu5800\":3.129,\"stu5807\":2.79,\"stu5808\":4.089,\"stu5810\":0.761,\"stu5815\":2.32,\"stu5818\":0.558,\"stu5825\":2.701,\"stu5826\":2.076,\"stu5827\":0.46,\"stu5828\":0.536,\"stu5829\":3.249,\"stu5835\":1.163,\"stu5837\":0.425,\"stu5839\":0.547,\"stu5843\":2.237,\"stu5846\":1.375,\"stu5849\":0.809,\"stu5850\":2.046,\"stu5855\":0.268,\"stu5856\":0.495,\"stu5857\":2.217,\"stu5859\":2.231,\"stu5860\":0.834,\"stu5862\":0.651,\"stu5864\":1.129,\"stu5866\":0.372,\"stu5867\":5.958,\"stu5870\":3.38,\"stu5874\":1.799,\"stu5880\":0.576},")
		# initial hamer reputation of Wiki 1a and 1b (724, 733)
		# req.body.prepend("\"initial_hamer_reputation\":{\"stu5687\":1.267,\"stu5787\":2.15,\"stu5790\":3.426,\"stu5791\":1.48,\"stu5795\":1.121,\"stu5796\":0.643,\"stu5797\":2.159,\"stu5800\":1.269,\"stu5801\":2.659,\"stu5804\":2.16,\"stu5806\":0.809,\"stu5807\":2.096,\"stu5808\":4.223,\"stu5810\":1.034,\"stu5811\":3.765,\"stu5814\":0.931,\"stu5815\":2.504,\"stu5818\":0.257,\"stu5820\":2.477,\"stu5822\":2.31,\"stu5824\":2.113,\"stu5825\":2.856,\"stu5826\":2.296,\"stu5827\":0.438,\"stu5828\":0.729,\"stu5829\":3.388,\"stu5830\":0.893,\"stu5832\":2.551,\"stu5835\":1.579,\"stu5837\":0.578,\"stu5839\":0.743,\"stu5840\":0.996,\"stu5841\":0.506,\"stu5843\":2.432,\"stu5846\":1.633,\"stu5848\":0.757,\"stu5849\":0.299,\"stu5850\":2.272,\"stu5855\":0.334,\"stu5856\":0.672,\"stu5857\":2.415,\"stu5859\":2.427,\"stu5860\":0.627,\"stu5862\":0.884,\"stu5863\":0.723,\"stu5864\":1.534,\"stu5866\":0.505,\"stu5867\":2.2,\"stu5868\":2.005,\"stu5869\":0.755,\"stu5870\":0.252,\"stu5871\":2.144,\"stu5873\":0.528,\"stu5874\":0.923,\"stu5875\":1.974,\"stu5876\":1.33,\"stu5880\":0.782},")
		# initial hamer reputation of program 1 (735)
		# req.body.prepend("\"initial_hamer_reputation\":{\"stu4381\":2.649, \"stu5415\":3.022, \"stu5687\":3.578, \"stu5787\":3.142, \"stu5788\":2.424, \"stu5789\":0.134, \"stu5790\":2.885, \"stu5792\":2.27, \"stu5793\":2.317, \"stu5794\":2.219, \"stu5795\":1.232, \"stu5796\":0.832, \"stu5797\":2.946, \"stu5798\":0.225, \"stu5799\":5.365, \"stu5800\":2.749, \"stu5801\":4.161, \"stu5802\":4.78, \"stu5803\":0.366, \"stu5804\":0.262, \"stu5805\":3.016, \"stu5806\":0.561, \"stu5807\":3.028, \"stu5808\":3.435, \"stu5810\":3.664, \"stu5812\":2.638, \"stu5813\":2.621, \"stu5814\":3.035, \"stu5815\":2.985, \"stu5816\":0.11, \"stu5817\":2.16, \"stu5818\":0.448, \"stu5821\":0.294, \"stu5822\":1.874, \"stu5823\":3.339, \"stu5824\":3.597, \"stu5825\":4.033, \"stu5826\":2.962, \"stu5827\":1.49, \"stu5828\":3.208, \"stu5830\":1.211, \"stu5832\":0.406, \"stu5833\":3.04, \"stu5836\":3.396, \"stu5838\":4.519, \"stu5839\":2.974, \"stu5840\":1.952, \"stu5843\":3.515, \"stu5844\":0.627, \"stu5845\":2.355, \"stu5846\":3.604, \"stu5847\":3.847, \"stu5848\":1.488, \"stu5849\":2.078, \"stu5850\":2.957, \"stu5851\":2.774, \"stu5852\":2.345, \"stu5853\":1.717, \"stu5854\":2.275, \"stu5855\":2.216, \"stu5856\":1.4, \"stu5857\":3.463, \"stu5858\":3.132, \"stu5859\":3.327, \"stu5860\":0.965, \"stu5861\":1.683, \"stu5862\":1.647, \"stu5863\":0.457, \"stu5864\":3.901, \"stu5866\":2.402, \"stu5867\":1.509, \"stu5868\":0.198, \"stu5869\":1.434, \"stu5870\":0.43, \"stu5871\":0.654, \"stu5872\":0.854, \"stu5873\":2.645, \"stu5874\":1.988, \"stu5875\":0.089, \"stu5876\":3.438, \"stu5878\":3.763, \"stu5880\":2.444, \"stu5881\":0.316},")
		
		# [new way] initial hamer reputation of program 1 (735)
		# req.body.prepend("\"initial_hamer_reputation\":{\"stu4381\":3.016,\"stu5415\":2.509,\"stu5687\":2.932,\"stu5787\":2.772,\"stu5788\":1.871,\"stu5789\":0.145,\"stu5790\":2.712,\"stu5792\":2.398,\"stu5793\":1.472,\"stu5794\":1.657,\"stu5795\":2.281,\"stu5796\":1.184,\"stu5797\":2.984,\"stu5798\":0.236,\"stu5799\":3.37,\"stu5800\":0.922,\"stu5801\":4.182,\"stu5802\":3.474,\"stu5803\":0.329,\"stu5804\":0.312,\"stu5805\":3.066,\"stu5806\":0.409,\"stu5807\":2.655,\"stu5808\":2.911,\"stu5810\":3.118,\"stu5812\":2.134,\"stu5813\":1.558,\"stu5814\":2.556,\"stu5815\":2.661,\"stu5816\":0.117,\"stu5817\":0.952,\"stu5818\":0.627,\"stu5821\":0.372,\"stu5822\":1.876,\"stu5823\":3.322,\"stu5824\":2.997,\"stu5825\":3.568,\"stu5826\":2.919,\"stu5827\":0.653,\"stu5828\":2.329,\"stu5830\":0.528,\"stu5832\":0.435,\"stu5833\":2.611,\"stu5836\":2.619,\"stu5838\":4.454,\"stu5839\":3.161,\"stu5840\":1.846,\"stu5843\":2.978,\"stu5844\":0.757,\"stu5845\":2.696,\"stu5846\":3.267,\"stu5847\":3.752,\"stu5848\":1.401,\"stu5849\":1.725,\"stu5850\":2.556,\"stu5851\":2.022,\"stu5852\":2.401,\"stu5853\":1.919,\"stu5854\":2.344,\"stu5855\":2.243,\"stu5856\":2.059,\"stu5857\":3.441,\"stu5858\":2.716,\"stu5859\":3.059,\"stu5860\":1.301,\"stu5861\":1.776,\"stu5862\":2.327,\"stu5863\":0.614,\"stu5864\":3.732,\"stu5866\":0.633,\"stu5867\":1.175,\"stu5868\":0.219,\"stu5869\":1.955,\"stu5870\":0.466,\"stu5871\":1.153,\"stu5872\":2.431,\"stu5873\":2.555,\"stu5874\":2.184,\"stu5875\":0.102,\"stu5876\":3.056,\"stu5878\":5.014,\"stu5880\":1.636,\"stu5881\":0.316},")
		
		# Eg.
		# "{"initial_hamer_reputation": {"stu1": 0.90, "stu2":0.88, "stu3":0.93, "stu4":0.8, "stu5":0.93, "stu8":0.93},  #optional
		# "initial_lauw_reputation": {"stu1": 1.90, "stu2":0.98, "stu3":1.12, "stu4":0.94, "stu5":1.24, "stu8":1.18},  #optional
		# "expert_grades": {"submission1": 90, "submission2":88, "submission3":93},  #optional
		# "submission1": {"stu1":91, "stu3":99},"submission2": {"stu5":92, "stu8":90},"submission3": {"stu2":91, "stu4":88}}"
		req.body.prepend('{')
		puts req.body
		puts
		response = Net::HTTP.new('152.7.99.160', 3000).start {|http| http.request(req)}
		puts "Response #{response.code} #{response.message}:
          #{response.body}"
        puts
        @@response_body = response.body
		redirect_to action: 'client'
	end
end