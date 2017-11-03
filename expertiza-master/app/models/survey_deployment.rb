class SurveyDeployment < ActiveRecord::Base
  validates_presence_of :start_date
  validates_presence_of :end_date
  validate :valid_start_end_time?

  def valid_start_end_time?
    if end_date.nil? || start_date.nil?
      errors[:base] << "The start and end time should be specified."
      return false
    end
    if !end_date.nil? && !start_date.nil? && (end_date - start_date) < 0
      errors[:base] << "The End Date should be after the Start Date."
      return false
    end
    if !end_date.nil? && end_date < Time.now
      errors[:base] << "The End Date should be in the future."
      return false
    end
    true
  end

  # implemented in both AssignmentSurveyDeployment and CourseSurveyDeployment models
  def parent_name
  end

  # implemented in both AssignmentSurveyDeployment and CourseSurveyDeployment models
  def response_maps
  end
end
