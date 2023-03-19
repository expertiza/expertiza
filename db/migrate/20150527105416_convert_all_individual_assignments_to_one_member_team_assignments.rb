class ConvertAllIndividualAssignmentsToOneMemberTeamAssignments < ActiveRecord::Migration[4.2]
  def self.up
    # case 1 (team_num == participants_num and has no topic):
    # change ParticipantReviewResponseMap -> TeamReviewResponseMap in response_maps table
    #    assignment_ids =  [2, 13, 15, 17, 22, 24, 25, 29, 30, 38, 41, 42, 43, 44, 45, 46, 48, 50, 51, 52, 62, 64, 66, 74, 89, 124, 127, 128, 129, 142, 150, 156, 158, 159, 161, 162, 163, 164, 171, 172, 176, 177, 178, 181, 182, 183, 184, 185, 186, 187, 188, 189, 191, 192, 193, 194, 195, 196, 197, 198, 203, 204, 205, 206, 207, 208, 209, 212, 214, 215, 216, 217, 232, 241, 244, 257, 260, 265, 267, 288, 295, 297, 306, 322, 333, 336, 346, 390, 395, 398, 406, 408, 409, 410, 411, 421, 433, 439, 441, 455, 465, 473, 475, 479, 482, 487, 488, 496, 498, 499, 503, 505, 508, 509, 514, 515, 517, 518, 536, 540, 541, 542, 564, 590, 591, 598]
    #    assignment_ids.each do |assignment_id|
    #      response_maps = ParticipantReviewResponseMap.where(reviewed_object_id: assignment_id)
    #      response_maps.each do |response_map|
    #        response_map.update_attribute(:type,'TeamReviewResponseMap')
    #      end
    #    end

    # case 2 (team_num == participants_num and has topic(s)):
    # check whether each topic in sign_up_topic table or not
    # if not, create a topic called 'missing_team'
    # check each participant.topic has corresponding sign_up_team record
    # if not, create a new sign_up_team record
    # change ParticipantReviewResponseMap -> TeamReviewResponseMap in response_maps table
    #    assignment_ids = [76, 139, 165, 175, 270, 271, 317, 344, 386, 444, 512, 580, 589, 607]
    #    assignment_ids.each do |assignment_id|
    #      assignment = Assignment.find(assignment_id)
    #      participants = AssignmentParticipant.where(parent_id: assignment_id)
    #      participants.each do |participant|
    #        team_id = TeamsUser.team_id(assignment_id, participant.user_id)
    #        if team_id.nil?
    #          #create team
    #            new_team = AssignmentTeam.create(name: assignment.name + "_" + participant.id.to_s, parent_id: assignment_id)
    #            team_id = new_team.id
    #            #add teams_users record
    #            TeamsUser.create(team_id: new_team.id, user_id: participant.user_id)
    #        end
    #        if participant.topic_id
    #          if !SignUpTopic.exists?(participant.topic_id)
    #            SignUpTopic.create(id: participant.topic_id, topic_name: 'missing_topic', assignment_id: assignment_id, max_choosers: 10, bookmark_rating_rubric_id: '')
    #          end
    #          if !SignedUpTeam.exists?(team_id: team_id, topic_id: participant.topic_id)
    #            SignedUpTeam.create(topic_id: participant.topic_id, team_id: team_id, is_waitlisted: false)
    #          end
    #        end
    #        #for the ParticipantReviewResponseMaps record, change them to TeamReviewResponseMap record
    #          response_maps = ParticipantReviewResponseMap.where(reviewed_object_id: assignment_id)
    #        response_maps.each do |response_map|
    #          response_map.update_attribute(:type,'TeamReviewResponseMap')
    #        end
    #    end
    #  end
  end
end
