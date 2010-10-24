class CodeReviewFile < ActiveRecord::Base
  belongs_to :participant, :class_name => 'Participant', :foreign_key => 'participantid'
  has_many :code_review_comments, :class_name => 'CodeReviewComments', :foreign_key => 'codefileid'

  validates_presence_of :name

  def self.getParticipantCodeFiles participant_id
    CodeReviewFile.find_all_by_participantid(participant_id)
  end
  
  def getNumLines()
    contents.split("\n").length - 1  
  end

end
