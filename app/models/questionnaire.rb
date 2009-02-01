class Questionnaire < ActiveRecord::Base
    # for doc on why we do it this way, 
    # see http://blog.hasmanythrough.com/2007/1/15/basic-rails-association-cardinality
    has_many :assignments, :foreign_key => "review_questionnaire_id" # Associates to assignments through review_questionnaire_id - 2/1/2009 this is no longer accurate as we have more than review_questionnaire types
    has_many :questions # the collection of questions associated with this Questionnaire
    belongs_to :questionnaire_type, :foreign_key => "type_id" # the type of this Questionnaire
    has_many :assignments_questionnaires # the join between Assignment and Questionnaire - 2/1/2009 may no longer be in use
    belongs_to :instructor, :class_name => "User", :foreign_key => "instructor_id" # the creator of this questionnaire

    
    validates_presence_of :name
    validates_numericality_of :max_question_score
    validates_numericality_of :min_question_score
    
    DEFAULT_MIN_QUESTION_SCORE = 0  # The lowest score that a reviewer can assign to any questionnaire question
    DEFAULT_MAX_QUESTION_SCORE = 5  # The highest score that a reviewer can assign to any questionnaire question
    
    # Does this questionnaire contain true/false questions?
    def true_false_questions?
      for question in questions
        if question.true_false
          return true
        end
      end
      
      return false
    end
    
    # Remove question and advice associated with this
    # questionnaire
    def delete_questions
      for question in questions
        for advice in question.question_advices
          advice.destroy
        end
        question.destroy
      end
    end
    
    # remove assignments associated with this
    # questionnaire
    def delete_assignments
      for assignment in assignments
        assignment.destroy
      end
    end
    
    # if the associated assignments exist, return true
    def assignments_exist?
      return false if assignments == nil or assignments.length == 0
      return true
    end
    
    # validate the entries for this questionnaire
    def validate  
      if max_question_score < 1
        errors.add(:max_question_score, "The maximum question score must be a positive integer.") 
      end
      if min_question_score >= max_question_score
        errors.add(:min_question_score, "The minimum question score must be less than the maximum")
      end
      
      results = Questionnaire.find(:all, 
                            :conditions => ["id <> ? and name = ? and instructor_id = ?", 
                            id, name, instructor_id])
      errors.add(:name, "Questionnaire names must be unique.") if results != nil and results.length > 0
  end   
end
