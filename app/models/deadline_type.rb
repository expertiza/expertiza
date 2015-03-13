class DeadlineType < ActiveRecord::Base
  def find_with_name(name)
    DeadlineType.where(name: name)
  end
end
