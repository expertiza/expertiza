# == Schema Information
#
# Table name: assignment_questionnaires
#
#  id                   :integer          not null, primary key
#  assignment_id        :integer
#  questionnaire_id     :integer
#  user_id              :integer
#  notification_limit   :integer          default(15), not null
#  questionnaire_weight :integer          default(0), not null
#  used_in_round        :integer
#

class AssignmentQuestionnaire < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :questionnaire


end
