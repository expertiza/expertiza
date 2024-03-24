class TeamsParticipant < ApplicationRecord
    belongs_to :user
    belongs_to :participant
    belongs_to :team
    has_one :team_user_node, foreign_key: 'node_object_id', dependent: :destroy
    has_paper_trail
  
    # Enhances readability by providing a clearer method name and leveraging Ruby's conditional expressions
    def display_name(ip_address = nil)
      display_name = user.name(ip_address)
      display_name += ' (Mentor)' if MentorManagement.user_a_mentor?(user)
      display_name
    end
  
    # Simplifies the delete method while preserving logic
    def remove
      TeamUserNode.find_by(node_object_id: id)&.destroy
      destroy
      team.destroy if team.teams_users.empty?
    end
  
    def get_team_members(team_id)
      # Method body if needed
    end
  
    # Class methods for handling team and user associations and queries
    class << self
      # Streamlines the removal process
      def remove_team(user_id, team_id)
        find_by(team_id: team_id, user_id: user_id)&.destroy
      end
  
      def first_by_team_id(team_id)
        where(team_id: team_id).first
      end
  
      def team_empty?(team_id)
        where(team_id: team_id).blank?
      end
  
      def add_member_to_invited_team(invitee_user_id, invited_user_id, assignment_id)
        can_add_member = false
        where(user_id: invitee_user_id).each do |team|
          new_team = AssignmentTeam.find_by(id: team.team_id, parent_id: assignment_id)
          can_add_member = new_team.add_member(User.find(invited_user_id), assignment_id) unless new_team.nil?
        end
        can_add_member
      end
  
      def team_id(assignment_id, user_id)
        find_team_id_for_user_and_assignment(assignment_id, user_id)
      end
  
      def find_by_team_and_user(team_id, user_id)
        find_by_team_id_and_user_id_or_participant_id(team_id, user_id)
      end
  
      def where_users_and_assignment(user_ids, assignment_id)
        participants = Participant.where(user_id: user_ids, parent_id: assignment_id)
        where(user_id: user_ids).or(where(participant_id: participants.ids))
      end
  
      private
  
      def find_team_id_for_user_and_assignment(assignment_id, user_id)
        return nil if assignment_id.nil?
        
        participant_id = Assignment.find(assignment_id).participants.find_by(user_id: user_id).id
        where(user_id: user_id).or(where(participant_id: participant_id)).find_each do |team_user|
          return team_user.team_id if team_user.team.parent_id == assignment_id
        end
  
        nil
      end
  
      def find_by_team_id_and_user_id_or_participant_id(team_id, user_id)
        team_user = find_by(team_id: team_id, user_id: user_id)
        return team_user if team_user.present?
  
        participant_id = find_by_user_and_assignment(user_id, Team.find(team_id).parent_id)&.id
        find_by(team_id: team_id, participant_id: participant_id) unless participant_id.nil?
      end
    end
  
    def user
      participant&.user || super
    end
  
    def user_id
      user&.id || super
    end
  
    # Encapsulates the query logic within a helper method
    def self.find_by_user_and_assignment(user_id, assignment_id)
      Assignment.find(assignment_id)&.participants&.find_by(user_id: user_id)
    end
  end
  