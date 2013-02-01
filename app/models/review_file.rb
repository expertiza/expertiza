class ReviewFile < ActiveRecord::Base
  # Associate the author (participant) with the file
  belongs_to :participant, :class_name => 'Participant',
             :foreign_key => 'author_participant_id'

  # Associate the review_comments with the review_file
  has_many :review_comments, :class_name => 'ReviewComment',
           :foreign_key => 'review_file_id'


  #attr_accessor :filepath, :author_participant_id, :version_number

  # Returns the version_number of the collectively most recent version of code
  #   review files submitted by participant (and all members by the team if any)
  def self.get_max_version_num(participant)
    # Find the max version number of code submitted by 'participant'
    file = ReviewFile.find(
        :first, :conditions => ['author_participant_id = ?', participant.id],
        :order => 'version_number desc')
    #if file
    #  max_version_num = file.version_number
    #else
    #  max_version_num = 0
    #end
    max_version_num = file.nil? ? 0 : file.version_number


    # For all other members of the team, find the most recent version of code
    #   review files submitted by any of them.
    if participant.assignment.team_assignment
      participant.team.get_participants.each { |member|
        file = ReviewFile.find(
            :first, :conditions => ['author_participant_id = ?', member.id],
            :order => 'version_number desc')

        #if file
        #  max_member_version = file.version_number
        #else
        #  max_member_version = 0
        #end

        max_member_version  = file.nil? ? 0 : file.version_number

        max_version_num = max_member_version if max_member_version > max_version_num
      }
    end
    puts max_version_num
    return max_version_num
  end


  # Returns row in the ReviewFile table that has a filepath equal to one
  #   computed by the concatenation of this method's arguments.
  def self.get_file(code_review_dir, version_number, base_file_name)
    filepath = code_review_dir + ReviewFilesHelper::VERSION_DIR_SUFFIX +
               version_number.to_s + '//' + base_file_name
    ReviewFile.find_by_filepath(filepath)
  end



end
