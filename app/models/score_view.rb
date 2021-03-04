class ScoreView < ActiveRecord::Base
  # setting this to false so that factories can be created
  # to test the grading of weighted quiz questionnaires
  def readonly?
    false
  end
end
