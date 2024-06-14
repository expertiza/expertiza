class Waitlist < ApplicationRecord
	def self.cancel_all_waitlists(team_id, assignment_id)
		waitlisted_topics = SignUpTopic.find_waitlisted_topics_for_team(assignment_id, team_id)
		if not waitlisted_topics.nil?
			SignedUpTeam.destroy(waitlisted_topics.map(&:id))
		end
	end

	def self.remove_from_waitlists(team_id)
		signups = SignedUpTeam.where(team_id: team_id)
		signups.each do |signup|
			signup_topic_id = signup.topic_id
			signup.destroy
			non_waitlisted_users = SignedUpTeam.where(topic_id: signup_topic_id, is_waitlisted: false)
			max_choosers = SignUpTopic.find(signup_topic_id).max_choosers
			next unless non_waitlisted_users.length < max_choosers

			first_waitlisted_team = SignedUpTeam.find_by(topic_id: signup_topic_id, is_waitlisted: true)
			SignUpTopic.assign_to_first_waiting_team(first_waitlisted_team) if first_waitlisted_team
		end
	end

    # NOTE: TODO: This method belongs to the waitlist related code.
    def self.reassign_topic(session_user_id, assignment_id, topic_id)
      # find whether assignment is team assignment
      assignment = Assignment.find(assignment_id)

      # making sure that the drop date deadline hasn't passed
      dropDate = AssignmentDueDate.where(parent_id: assignment.id, deadline_type_id: '6').first
      if dropDate.nil? || dropDate.due_at >= Time.now
        # if team assignment find the creator id from teamusers table and teams
        # ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
        # to treat all assignments as team assignments
        # users_team will contain the team id of the team to which the user belongs
        users_team = SignedUpTeam.find_team_users(assignment_id, session_user_id)
        signup_record = SignedUpTeam.where(topic_id: topic_id, team_id:  users_team[0].t_id).first
        assignment = Assignment.find(assignment_id)
        # if a confirmed slot is deleted then push the first waiting list member to confirmed slot if someone is on the waitlist
        unless assignment.is_intelligent?
          unless signup_record.try(:is_waitlisted)
            # find the first wait listed user if exists
            first_waitlisted_user = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first

            unless first_waitlisted_user.nil?
              # As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
              ### Bad policy!  Should be changed! (once users are allowed to specify waitlist priorities) -efg
              first_waitlisted_user.is_waitlisted = false
              first_waitlisted_user.save

              # ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
              # to treat all assignments as team assignments
              Waitlist.cancel_all_waitlists(first_waitlisted_user.team_id, assignment_id)
            end
          end
        end
        signup_record.destroy unless signup_record.nil?
        ExpertizaLogger.info LoggerMessage.new('SignUpTopic', session_user_id, "Topic dropped: #{topic_id}")
      end # end condition for 'drop deadline' check
    end

    def self.assign_to_first_waiting_team(next_wait_listed_team)
      team_id = next_wait_listed_team.team_id
      team = Team.find(team_id)
      assignment_id = team.parent_id
      next_wait_listed_team.is_waitlisted = false
      next_wait_listed_team.save
      Waitlist.cancel_all_waitlists(team_id, assignment_id)
    end

    def update_waitlisted_users(max_choosers)
      num_of_users_promotable = max_choosers.to_i - self.max_choosers.to_i
      num_of_users_promotable.times do
        next_wait_listed_team = SignedUpTeam.where(topic_id: id, is_waitlisted: true).first
        # if slot exist, then confirm the topic for this team and delete all waitlists for this team
        SignUpTopic.assign_to_first_waiting_team(next_wait_listed_team) if next_wait_listed_team
      end
    end

    # NOTE: This can be moved to signed_up_team.
    def users_on_waiting_list
      waitlisted_signed_up_teams = SignedUpTeam.where(topic_id: id, is_waitlisted: 1)
      waitlisted_users = []
      if waitlisted_signed_up_teams.present?
        waitlisted_signed_up_teams.each do |waitlisted_signed_up_team|
          assignment_team = AssignmentTeam.find(waitlisted_signed_up_team.team_id)
          waitlisted_users << assignment_team.users
        end
      end
      waitlisted_users.flatten
    end
end
