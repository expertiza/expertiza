module AutomaticReviewMappingHelper
	class AutomaticReviewMappingHelper

		attr_accessor :assignment_id, :participants, :teams, :max_team_size, :student_review_num, :submission_review_num, :calibrated_artifacts_num, :uncalibrated_artifacts_num, :teams_with_calibrated_artifacts, :teams_with_uncalibrated_artifacts

		def initialize(params)
			@assignment_id = params[:id].to_i
    		@participants = AssignmentParticipant.where(parent_id: params[:id].to_i).to_a.reject {|p| p.can_review == false }.shuffle!
    		@teams = AssignmentTeam.where(parent_id: params[:id].to_i).to_a.shuffle!
    		@max_team_size = Integer(params[:max_team_size]) # Assignment.find(assignment_id).max_team_size
    		@student_review_num = params[:num_reviews_per_student].to_i
    		@submission_review_num = params[:num_reviews_per_submission].to_i
    		@calibrated_artifacts_num = params[:num_calibrated_artifacts].to_i
    		@uncalibrated_artifacts_num = params[:num_uncalibrated_artifacts].to_i
    		@teams_with_calibrated_artifacts = []
      		@teams_with_uncalibrated_artifacts = []
    	end

    	def create_teams_if_individual_assignment
    		if @teams.empty? and @max_team_size == 1
     			 @participants.each do |participant|
        		 next if TeamsUser.team_id(@assignment_id, participant.user.id)
        		 team = AssignmentTeam.create_team_and_node(@assignment_id)
        		 ApplicationController.helpers.create_team_users(participant.user, team.id)
        		 @teams << team
                 end
    		end
    	end

    	def check_if_all_artifacts_num_are_zero(flash,params)
    		
    		if @calibrated_artifacts_num == 0 and @uncalibrated_artifacts_num == 0
    			true
    		else
    			false
    		end

    	end

    	def assign_reviews_for_artifacts_num_zero(flash,params)
    		
    			if @student_review_num == 0 and @submission_review_num == 0
    				begin
        			raise "Please choose either the number of reviews per student or the number of reviewers per team (student)."
        			rescue Exception => e
        			yield e
        		    end
        			#flash[:error] = "Please choose either the number of reviews per student or the number of reviewers per team (student)."
      			elsif (@student_review_num != 0 and @submission_review_num == 0) or (@tudent_review_num == 0 and @submission_review_num != 0)
        			# REVIEW: mapping strategy
             		yield
      			else
      				begin
        			raise "Please choose either the number of reviews per student or the number of reviewers per team (student), not both."
        			rescue Exception => e
        			yield e
        			#flash[:error] = "Please choose either the number of reviews per student or the number of reviewers per team (student), not both."
            		end
           
            	end
    	end

    	def assign_reviews_for_artifacts_num_not_zero(params)
    		
    		ReviewResponseMap.where(reviewed_object_id: @assignment_id, calibrate_to: 1).each do |response_map|
        	@teams_with_calibrated_artifacts << AssignmentTeam.find(response_map.reviewee_id)
      		end
      		@teams_with_uncalibrated_artifacts = @teams - @teams_with_calibrated_artifacts
      		# REVIEW: mapping strategy
      		yield
      		
      		# REVIEW: mapping strategy
      		# since after first mapping, participants (delete_at) will be nil
      		@participants = AssignmentParticipant.where(parent_id: params[:id].to_i).to_a.reject {|p| p.can_review == false }.shuffle!
      		yield
      		

    	end
	end
end
