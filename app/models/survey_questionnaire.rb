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

class SurveyQuestionnaire < Questionnaire
    def after_initialize
      self.display_type = 'Survey' 
    end
end
