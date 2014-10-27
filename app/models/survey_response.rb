# == Schema Information
#
# Table name: survey_responses
#
#  id                   :integer          not null, primary key
#  score                :integer
#  comments             :text
#  assignment_id        :integer          default(0), not null
#  question_id          :integer          default(0), not null
#  survey_id            :integer          default(0), not null
#  email                :string(255)
#  survey_deployment_id :integer
#

class SurveyResponse < ActiveRecord::Base
 belongs_to :assignment
 belongs_to :questionnaire
 belongs_to :question
 
end
