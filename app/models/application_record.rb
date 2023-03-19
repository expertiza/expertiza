# ActiveRecord models will inherit from ApplicationRecord by default instead
# of ActiveRecord::Base
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
