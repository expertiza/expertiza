class ReviewFile < ActiveRecord::Base
  # Associate the author (participant) with the file
  belongs_to :participant, :class_name => 'Participant',
             :foreign_key => 'author_participant_id'

  # Associate the review_comments with the review_file
  has_many :review_comments, :class_name => 'ReviewComment',
           :foreign_key => 'review_file_id'


  # Returns the version_number of the collectively most recent version of code
  #   review files submitted by participant (and all members by the team if any)
  def self.get_max_version_num(participant)
    # Find the max version number of code submitted by 'participant'
    file = ReviewFile.find(
        :first, :conditions => ['author_participant_id = ?', participant.id],
        :order => 'version_number desc')
    if file
      max_version_num = file.version_number
    else
      max_version_num = 0
    end

    # For all other members of the team, find the most recent version of code
    #   review files submitted by any of them.
    if participant.assignment.team_assignment
      participant.team.get_participants.each { |member|
        file = ReviewFile.find(
            :first, :conditions => ['author_participant_id = ?', member.id],
            :order => 'version_number desc')

        if file
          max_member_version = file.version_number
        else
          max_member_version = 0
        end

        max_version_num = max_version_num > max_member_version ?
            max_version_num : max_member_version
      }
    end

    return max_version_num
  end



end
