# This is one type of Questionnaire and  as intuitively expected this model class
# derives from Questionnaire.

# This implements Rubric(type) specific model methods ( Rubric does not have any type specific 
# functionality). These methods are invoked when called by any activeRecord object(row) of 
# questionnaires table with type 'Rubric'  

class  Rubric < Questionnaire
    # for doc on why we do it this way, 
    # see http://blog.hasmanythrough.com/2007/1/15/basic-rails-association-cardinality
    
    # can these be inherited too?   
    validates_presence_of :name
    validates_numericality_of :max_question_score
    validates_numericality_of :min_question_score
        
     def update_mapping
           redirect_to :action => 'list' ,:type_id=> type_id
     end
    
end
