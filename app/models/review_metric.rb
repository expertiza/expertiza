class ReviewMetric < ActiveRecord::Base
	belongs_to :response_map, class_name: 'ResponseMap', foreign_key: 'response_id'
    attr_accessor :volume, :integer
    attr_accessor :suggestion, :boolean
    attr_accessor :problem, :boolean
    attr_accessor :offensive_term, :boolean

    def self.check_suggestion(reviewer_id,assignment_id)
    end

    def self.check_offensive_term(reviewer_id,assignment_id)
    	
    end

    def self.get_review_summary(reviewer_id,assignment_id)
    end

    def self.get_word_count(reviewer_id,assignment_id)
    end 



end
