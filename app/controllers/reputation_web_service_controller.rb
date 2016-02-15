require 'json'
require 'uri'
require 'net/http'

class ReputationWebServiceController < ApplicationController

	@@json_params = ''

	def action_allowed?
	  ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
	end

	def db_query(assignment_id, hasTopic)
	  query='SELECT U.id, RM.reviewee_id as submission_id, '+
		    'sum(A.answer * Q.weight) / sum(QN.max_question_score * Q.weight) * 100 as total_score '+
			# new way to calculate the grades of coding artifacts
			#'100 - SUM((QN.max_question_score-A.answer) * Q.weight) AS total_score '+
			'from answers A  '+
			'inner join questions Q on A.question_id = Q.id '+
			'inner join questionnaires QN on Q.questionnaire_id = QN.id  '+
			'inner join responses R on A.response_id = R.id  '+
			'inner join response_maps RM on R.map_id = RM.id  '+
			'inner join participants P on P.id = RM.reviewer_id '+
			'inner join users U on U.id = P.user_id '+
			'inner join teams T on T.id = RM.reviewee_id '
			query += 'inner join signed_up_teams SU_team on SU_team.team_id = T.id ' if hasTopic == true
			query += 'where RM.type="ReviewResponseMap"  '+
			'and RM.reviewed_object_id = '+  assignment_id.to_s + ' ' +
			'and A.answer is not null '+
			'and Q.type ="Criterion" '+
			#If one assignment is varying rubric by round (724, 733, 736) or 2-round peer review with (735), 
			#the round field in response records corresponding to ReviewResponseMap will be 1 or 2, will not be null.
			'and R.round = 2 '  
			query+='and SU_team.is_waitlisted = 0 ' if hasTopic == true
			query+='group by RM.id  '+
			'order by RM.reviewee_id'

		result = ActiveRecord::Base.connection.execute(query)
		result.first
	end

	def json_generator

	end

	def client
		#@results = db_query(736, true)
		#@results = JSON.pretty_generate(my_json)
	end

	def send_post_request
		# https://www.socialtext.net/open/very_simple_rest_in_ruby_part_3_post_to_create_a_new_workspace
		# uri = URI.parse('http://152.7.99.160:3000//calculations/reputation_algorithms')

		req = Net::HTTP::Post.new('/calculations/reputation_algorithms', initheader = {'Content-Type' =>'application/json'})
		req.body = {}.to_json
		response = Net::HTTP.new('152.7.99.160', 3000).start {|http| http.request(req)}
		puts "Response #{response.code} #{response.message}:
          #{response.body}"
		redirect_to action: 'client'
	end
end