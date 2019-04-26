class ScoreView < ActiveRecord::Base
  def readonly?
    false
  end
end
