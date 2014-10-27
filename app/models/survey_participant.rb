# == Schema Information
#
# Table name: survey_participants
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  survey_deployment_id :integer
#

class SurveyParticipant < ActiveRecord::Base
end
