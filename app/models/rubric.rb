class Rubric < ActiveRecord::Base
    # for doc on why we do it this way, 
    # see http://blog.hasmanythrough.com/2007/1/15/basic-rails-association-cardinality
    has_many :assignments, :foreign_key => "review_rubric_id"
    has_many :questions
    
    validates_presence_of :name
    validates_numericality_of :max_question_score
    validates_numericality_of :min_question_score
    
    DEFAULT_MIN_QUESTION_SCORE = 0  # The lowest score that a reviewer can assign to any rubric question
    DEFAULT_MAX_QUESTION_SCORE = 5  # The highest score that a reviewer can assign to any rubric question
    
    def true_false_questions?
      for question in questions
        if question.true_false
          return true
        end
      end
      
      return false
    end
    
    def delete_questions
      for question in questions
        for advice in question.question_advices
          advice.destroy
        end
        question.destroy
      end
    end
    
    def delete_assignments
      for assignment in assignments
        assignment.destroy
      end
    end
    
    def assignments_exist?
      return false if assignments == nil or assignments.length == 0
      return true
    end
    
    def validate  
      if max_question_score < 1
        errors.add(:max_question_score, "The maximum question score must be a positive integer.") 
      end
      if min_question_score >= max_question_score
        errors.add(:min_question_score, "The minimum question score must be less than the maximum")
      end
      
      results = Rubric.find(:all, 
                            :conditions => ["id <> ? and name = ? and instructor_id = ?", 
                            id, name, instructor_id])
      errors.add(:name, "Rubric names must be unique.") if results != nil and results.length > 0
    end
end
