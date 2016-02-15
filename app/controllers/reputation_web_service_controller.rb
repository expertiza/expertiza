require 'json'
require 'uri'
require 'net/http'

class ReputationWebServiceController < ApplicationController

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
			if SignedUpTeam.where(team_id: team.id).first.is_waitlisted == false
				response_map.response.select{|r| r.round == 2}.each do |response|
					answers = Answer.where(response_id: response.id)
					max_question_score = answers.first.question.questionnaire.max_question_score
					temp_sum = 0
					weight_sum = 0
					answers.select{|a| a.question.type == 'Criterion' and !a.answer.nil?}.each do |answer|
						temp_sum += answer.answer * answer.question.weight
						weight_sum += answer.question.weight
					end
					peer_review_grade = 100.0 * temp_sum / (weight_sum * max_question_score)
					raw_data_array << [reviewer.id, team.id, peer_review_grade.round(3)]
				end
			end
		end
		raw_data_array
	end

	def json_generator
		@results = db_query(733, true)
		request_body = Hash.new
		inner_msg = Hash.new
		@results.each_with_index do |record, index|
			if !request_body.has_key?('submission' + record[1].to_s)
				request_body['submission' + record[1].to_s] = Hash.new
			end
			request_body['submission' + record[1].to_s]['stu' + record[0].to_s] = record[2]
		end
		request_body
	end

	def client
		#@results = db_query(736, true)
		#@results = JSON.pretty_generate(my_json)
	end

	def send_post_request
		# https://www.socialtext.net/open/very_simple_rest_in_ruby_part_3_post_to_create_a_new_workspace
		# uri = URI.parse('http://152.7.99.160:3000//calculations/reputation_algorithms')
		json_generator
		req = Net::HTTP::Post.new('/calculations/reputation_algorithms', initheader = {'Content-Type' =>'application/json'})
		req.body = json_generator.to_json
		puts req.body
		puts
		response = Net::HTTP.new('152.7.99.160', 3000).start {|http| http.request(req)}
		puts "Response #{response.code} #{response.message}:
          #{response.body}"
		redirect_to action: 'client', results: response.body
	end
end