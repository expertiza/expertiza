class ConvertAllIndividualAssignmentsToOneMemberTeamAssignments < ActiveRecord::Migration
  def self.up
  	assignment_ids =  [2, 3, 17, 21, 24, 27, 30, 36, 38, 39, 42, 47, 50, 62, 63, 66, 67, 72, 73, 74, 76, 77, 78, 79, 81, 82, 83, 85, 89, 90, 91, 92, 97, 98, 99, 100, 102, 104, 105, 106, 107, 110, 114, 116, 117, 124, 134, 147, 158, 159, 161, 162, 163, 164, 165, 175, 181, 182, 183, 184, 185, 191, 192, 193, 194, 195, 196, 197, 198, 199, 203, 204, 205, 206, 207, 208, 209, 211, 212, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 227, 228, 229, 230, 232, 234, 236, 237, 238, 239, 241, 242, 244, 245, 246, 253, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 270, 271, 272, 274, 282, 285, 288, 289, 292, 295, 296, 297, 303, 306, 308, 309, 310, 311, 312, 313, 314, 320, 322, 330, 333, 336, 344, 346, 386, 390, 395, 398, 399, 406, 408, 409, 410, 411, 421, 423, 433, 439, 440, 441, 443, 444, 445, 447, 455, 465, 468, 474, 475, 479, 481, 520]
  	assignment_ids.each do |assignment_id|
  		assignment = Assignment.find(assignment_id)
  		participants = Participant.where('parent_id', assignment.id)
  		participants.each do |participant|
	  		Team.create(name: assignment.name + "_" + rand(1000).to_s, parent_id: assignment.id, type: 'AssignmentTeam')
	  		#find the latest created team
	  		new_team = Team.order('id desc').first
	  		TeamsUser.create(team_id: new_team.id, user_id: participant.user_id)
	  		SignedUpTeam.create(topic_id: participant.topic_id, team_id: new_team.id, is_waitlisted: false) if participant.topic_id
	  		response_maps = ResponseMap.where(reviewee_id: participant.id)
	  		response_maps.each do |response_map|
	  			response_map.type = 'TeamReviewResponseMap'
	  			response_map.reviewee_id = new_team.id
	  			response_map.save
	  		end
	  	end
	end
  end
end
