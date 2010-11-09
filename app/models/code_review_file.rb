class CodeReviewFile < ActiveRecord::Base
  #associate the participant with the file
  belongs_to :participant, :class_name => 'Participant', :foreign_key => 'participantid'
  #associate the comments with the file
  has_many :code_review_comments, :class_name => 'CodeReviewComment', :foreign_key => 'codefileid'

  #force name to exists....
  validates_presence_of :name

  #static method to get the participant
  def self.getParticipantCodeFiles participant_id
    CodeReviewFile.find_all_by_participantid(participant_id)
  end
  
  #get number of lines....
  def getNumLines()
    contents.split("\n").length - 1  
  end

end
