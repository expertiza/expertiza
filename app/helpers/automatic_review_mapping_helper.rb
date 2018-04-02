module AutomaticReviewMappingHelper
  class AutomaticReviewMapping

    @@time_create_last_review_mapping_record= nil

    def initialize(params)
      @assignment_id = params[:id].to_i
      @participants = AssignmentParticipant.where(parent_id: @assignment_id).to_a.reject {|p| p.can_review == false }.shuffle!
      @teams = AssignmentTeam.where(parent_id: @assignment_id).to_a.shuffle!
      max_team_size = Integer(params[:max_team_size]) # Assignment.find(assignment_id).max_team_size
      # Create teams if its an individual assignment.
      if @teams.empty? and max_team_size == 1
        @participants.each do |participant|
          user = participant.user
          next if TeamsUser.team_id(@assignment_id, user.id)
          team = AssignmentTeam.create_team_and_node(@assignment_id)
          ApplicationController.helpers.create_team_users(user, team.id)
          @teams << team
        end
      end
      @student_review_num = params[:num_reviews_per_student].to_i
      @submission_review_num = params[:num_reviews_per_submission].to_i
      @calibrated_artifacts_num = params[:num_calibrated_artifacts].to_i
      @uncalibrated_artifacts_num = params[:num_uncalibrated_artifacts].to_i
      @participants_hash = {}
      @participants.each {|participant| @participants_hash[participant.id] = 0 }
    end

    attr_reader :assignment_id

    def automatic_review_mapping_strategy(params)
      if @calibrated_artifacts_num == 0 and @uncalibrated_artifacts_num == 0
        if @student_review_num == 0 and @submission_review_num == 0
          raise 'Please choose either the number of reviews per student or the number of reviewers per team (student).'
        elsif (@student_review_num != 0 and @submission_review_num == 0) or (@student_review_num == 0 and @submission_review_num != 0)
          execute_peer_review_strategy(@teams, @student_review_num, @submission_review_num,params)
          assign_reviewers_for_team(@student_review_num,params)
        else
          raise 'Please choose either the number of reviews per student or the number of reviewers per team (student), not both.'
        end
      else
        @teams_with_calibrated_artifacts = []
        @teams_with_uncalibrated_artifacts = []
        ReviewResponseMap.where(reviewed_object_id: @assignment_id, calibrate_to: 1).each do |response_map|
          @teams_with_calibrated_artifacts << AssignmentTeam.find(response_map.reviewee_id)
        end
        @teams_with_uncalibrated_artifacts = @teams - @teams_with_calibrated_artifacts
        execute_peer_review_strategy(@teams_with_calibrated_artifacts.shuffle!, @calibrated_artifacts_num, 0,params)
        assign_reviewers_for_team(@calibrated_artifacts_num,params)
        @participants = AssignmentParticipant.where(parent_id: @assignment_id).to_a.reject {|p| p.can_review == false }.shuffle!
        @participants_hash = {}
        @participants.each {|participant| @participants_hash[participant.id] = 0 }
        execute_peer_review_strategy(@teams_with_uncalibrated_artifacts.shuffle!, @uncalibrated_artifacts_num, 0,params)
        assign_reviewers_for_team(@uncalibrated_artifacts_num,params)
      end
    end

    private

    def execute_peer_review_strategy(teams, student_review_num = 0, submission_review_num = 0,params)
      if student_review_num != 0 and submission_review_num == 0
        @num_reviews_per_team = (@participants.size * student_review_num * 1.0 / teams.size).round
        @exact_num_of_review_needed = @participants.size * student_review_num
      elsif student_review_num == 0 and submission_review_num != 0
        @num_reviews_per_team = submission_review_num
        student_review_num = (teams.size * submission_review_num * 1.0 / (@participants.size)).round
        @exact_num_of_review_needed = teams.size * submission_review_num
        @student_review_num = student_review_num
      end
      if student_review_num >= teams.size
        raise 'You cannot set the number of reviews done \
      by each student to be greater than or equal to total number of teams \
      [or "participants" if it is an individual assignment].'
      end
      peer_review_strategy(teams, student_review_num,params)
    end

    def peer_review_strategy(teams, student_review_num,params)
      num_participants = @participants.size
      iterator = 0
      teams.each do |team|
        selected_participants = []
        if !team.equal? teams.last
          # need to even out the # of reviews for teams
          while selected_participants.size < @num_reviews_per_team
            num_participants_this_team = TeamsUser.where(team_id: team.id).size
            # If there are some submitters or reviewers in this team, they are not treated as normal participants.
            # They should be removed from 'num_participants_this_team'
            TeamsUser.where(team_id: team.id).each do |team_user|
              temp_participant = Participant.where(user_id: team_user.user_id, parent_id: @assignment_id).first
              num_participants_this_team -= 1 if temp_participant.can_review == false or temp_participant.can_submit == false
            end
            # if all outstanding participants are already in selected_participants, just break the loop.
            break if selected_participants.size == @participants.size - num_participants_this_team

            # generate random number
            if iterator == 0
              rand_num = rand(0..num_participants - 1)
            else
              min_value = @participants_hash.values.min
              # get the temp array including indices of participants, each participant has minimum review number in hash table.
              participants_with_min_assigned_reviews = []
              @participants.each do |participant|
                participants_with_min_assigned_reviews << @participants.index(participant) if @participants_hash[participant.id] == min_value
              end
              # if participants_with_min_assigned_reviews is blank
              if_condition_1 = participants_with_min_assigned_reviews.empty?
              # or only one element in participants_with_min_assigned_reviews, prohibit one student to review his/her own artifact
              if_condition_2 = (participants_with_min_assigned_reviews.size == 1 and TeamsUser.exists?(team_id: team.id, user_id: @participants[participants_with_min_assigned_reviews[0]].user_id))
              rand_num = if if_condition_1 or if_condition_2
                           # use original method to get random number
                           rand(0..num_participants - 1)
                         else
                           # rand_num should be the position of this participant in original array
                           participants_with_min_assigned_reviews[rand(0..participants_with_min_assigned_reviews.size - 1)]
                         end
            end
            # prohibit one student to review his/her own artifact
            next if TeamsUser.exists?(team_id: team.id, user_id: @participants[rand_num].user_id)

            if_condition_1 = (@participants_hash[@participants[rand_num].id] < student_review_num)
            if_condition_2 = (!selected_participants.include? @participants[rand_num].id)
            if if_condition_1 and if_condition_2
              # selected_participants cannot include duplicate num
              selected_participants << @participants[rand_num].id
              @participants_hash[@participants[rand_num].id] += 1
            end
            # remove students who have already been assigned enough num of reviews out of participants array
            @participants.each do |participant|
              if @participants_hash[participant.id] == student_review_num
                @participants.delete_at(rand_num)
                num_participants -= 1
              end
            end
          end
        else
          # REVIEW: num for last team can be different from other teams.
          # prohibit one student to review his/her own artifact and selected_participants cannot include duplicate num
          @participants.each do |participant|
            # avoid last team receives too many peer reviews
            if !TeamsUser.exists?(team_id: team.id, user_id: participant.user_id) and selected_participants.size < @num_reviews_per_team
              selected_participants << participant.id
              @participants_hash[participant.id] += 1
            end
          end
        end

        begin
          selected_participants.each {|index| ReviewResponseMap.where(reviewee_id: team.id, reviewer_id: index, reviewed_object_id: @assignment_id).first_or_create }
        rescue StandardError
          raise "Automatic assignment of reviewer failed."
        end
        iterator += 1
      end
    end

    def assign_reviewers_for_team(student_review_num,params)
      if ReviewResponseMap.where(reviewed_object_id: @assignment_id, calibrate_to: 0)
             .where("created_at > :time",
                    time: @@time_create_last_review_mapping_record).size < @exact_num_of_review_needed

        participants_with_insufficient_review_num = []
        @participants_hash.each do |participant_id, review_num|
          participants_with_insufficient_review_num << participant_id if review_num < student_review_num
        end
        unsorted_teams_hash = {}

        ReviewResponseMap.where(reviewed_object_id: @assignment_id,
                                calibrate_to: 0).each do |response_map|
          if unsorted_teams_hash.key? response_map.reviewee_id
            unsorted_teams_hash[response_map.reviewee_id] += 1
          else
            unsorted_teams_hash[response_map.reviewee_id] = 1
          end
        end
        teams_hash = unsorted_teams_hash.sort_by {|_, v| v }.to_h

        participants_with_insufficient_review_num.each do |participant_id|
          teams_hash.each do |team_id, _num_review_received|
            next if TeamsUser.exists?(team_id: team_id,
                                      user_id: Participant.find(participant_id).user_id)

            ReviewResponseMap.where(reviewee_id: team_id, reviewer_id: participant_id,
                                    reviewed_object_id: @assignment_id).first_or_create

            teams_hash[team_id] += 1
            teams_hash = teams_hash.sort_by {|_, v| v }.to_h
            break
          end
        end
      end
      @@time_create_last_review_mapping_record = ReviewResponseMap.
          where(reviewed_object_id: @assignment_id).
          last.created_at
    end
  end
end