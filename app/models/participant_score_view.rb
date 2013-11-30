class ParticipantScoreView < ActiveRecord::Base
  attr_accessor :response_id,:score,:weight,:questionaire_type,:max_question_score
end
