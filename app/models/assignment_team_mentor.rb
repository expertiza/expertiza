class AssignmentTeamMentor < ActiveRecord::Base
  belongs_to :assignment_team, class_name: "AssignmentTeam" ,foreign_key: "assignment_team_id"
  belongs_to :participant, foreign_key: "assignment_team_mentor_id"

  validates :assignment_team_id, presence: true
  validates :assignment_team_mentor_id, presence: true

  # Assign a team mentor provided an assignment_id is given
  def assignMentor(assignment_id)
    list = Participant.get_mentors(assignment_id)
    if list.count < 1
      # Return nil if no tas or instructors have been added as participants and unable to assign team mentor to current team
      return nil
    else
      # Hash to find current mentors assigned for current assignment. Keys of hash will be participant_ids and values are count of times
      # an id has been assigned to teams created for current assignment
      currentAssignedTeamMentors = {}
      list.each { |p| teamAssignedCount = AssignmentTeamMentor.where(assignment_team_mentor_id: p.id).count
      currentAssignedTeamMentors[p.id] = teamAssignedCount
      }
      currentAssignedTeamMentorsArray = currentAssignedTeamMentors.sort_by{ |id, teamsMentoredCount| teamsMentoredCount }
      # Assign assignment_team_mentor_id with the first participant_id retrieved from the sorted array.
      # This will be the mentor with the least number of assigned teams for the given assignment.
      self.assignment_team_mentor_id = currentAssignedTeamMentorsArray.first.first
    end
  end
  
  # Email assignment team mentor and assignment team participants of mentor assigned given the team_id we can send the email to the users.
  def email_mentor(team_id)
    members = TeamsUser.where(team_id: team_id)
    parent_id = Team.find_by(id: team_id).parent_id
    members_id=members.collect(&:user_id)
  #store the names and emails of the members by iterating through their ids.
    @user_name = []
    @user_email = []
    members_id.each do|i|
     @user_name.push(User.find_by(id: i).name) 
     @user_email.push(User.find_by(id: i).email)
    end
   user = User.find_by(id: TeamsUser.find_by(team_id: team_id).user_id)
     Mailer.notify_member(
      to: user.email,
      subject: "You have been assigned to mentor a team",
      body:{
        user_name: @user_name,
        user_email: @user_email
      }
    ).deliver_now
  end

  # Class method returns assigned team mentor with assignment_team_id.
  # Returns fields associated with User data model. i.e name,: fullname: and email:.
  def self.getAssignedMentor(assignment_team_id)
    # Checks to see if there is an assigned team mentor, if not return string "No assignment team mentor"
    if find_by(assignment_team_id: assignment_team_id).nil?
      return "No assignment team mentor"
    end
    mentor = find_by(assignment_team_id: assignment_team_id).participant.user
  end

end
