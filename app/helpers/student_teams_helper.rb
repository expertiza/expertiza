module StudentTeamsHelper
    # Determines if the pair programming button should be enabled
    def pair_programming_button_enabled?(team)
      team.pair_programming_request.nil? || team.pair_programming_request.zero?
    end
  
    # Fetches the status of pair programming for a team
    def pair_programming_status(team)
      return 'No Request' if team.pair_programming_request.nil? || team.pair_programming_request.zero?
      users = TeamsUser.where(team_id: team.id)
      pair_programming_team_status = users.none? { |user| user.pair_programming_status == "W" || user.pair_programming_status.nil? }
      pair_programming_team_status ? 'Yes' : 'Pending'
    end
  
    # Returns the display name for a user with optional anonymization
    def display_name(user, session_ip=nil)
      user.name(session_ip)
    end
  
    # Returns the full name for a user with optional anonymization
    def display_fullname(user, session_ip=nil)
      user.fullname(session_ip)
    end
  
    # Returns the email for a user with optional anonymization
    def display_email(user, session_ip=nil)
      user.email(session_ip)
    end
  
    # Determines if a teammate review is allowed for a particular team member
    def teammate_review_allowed?(assignment, team_user)
      assignment.duty_based_assignment? && !team_user.duty_id.nil? || !assignment.duty_based_assignment?
    end
  
    # Determines the role (if applicable) for a team member in a duty-based assignment
    def member_role(team_user)
      Duty.find(team_user.duty_id).name unless team_user.duty_id.nil?
    end
  
    # Checks if a user is a mentor
    def is_mentor?(user)
      MentorManagement.user_a_mentor?(user)
    end
end
  