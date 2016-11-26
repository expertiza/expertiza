class ReviewMetric < ActiveRecord::Base
belongs_to :review_response_map, class_name: 'ReviewResponseMap', foreign_key: 'response_id'

  attr_accessor :volume, :integer
  attr_accessor :suggestion, :integer
  attr_accessor :problem, :integer


  attr_accessor :offensive_term, :integer
end
