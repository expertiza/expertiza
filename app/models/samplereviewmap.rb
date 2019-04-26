class Samplereviewmap < ActiveRecord::Base
  belongs_to :assignment, foreign_key: 'assignment_id'
  belongs_to :response_map, foreign_key: 'response_map_id'
end
