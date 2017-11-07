class ScoreView < ActiveRecord::Base
  attr_accessible

  def readonly?
    true
  end
end
