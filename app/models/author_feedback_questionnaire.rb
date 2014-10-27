# == Schema Information
#
# Table name: questionnaires
#
#  id                  :integer          not null, primary key
#  name                :string(64)
#  instructor_id       :integer          default(0), not null
#  private             :boolean          default(FALSE), not null
#  min_question_score  :integer          default(0), not null
#  max_question_score  :integer
#  created_at          :datetime
#  updated_at          :datetime         not null
#  default_num_choices :integer
#  type                :string(255)
#  display_type        :string(255)
#  instruction_loc     :text
#  section             :string(255)
#

class AuthorFeedbackQuestionnaire < Questionnaire
  def after_initialize    
    self.display_type = 'Author Feedback' 
  end
  
  def symbol
    return "feedback".to_sym
  end  
  
  def get_assessments_for(participant)
    participant.get_feedback()  
  end


end
