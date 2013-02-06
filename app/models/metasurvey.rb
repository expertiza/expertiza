# This is one type of Questionnaire and  as intuitively expected this model class
# derives from Questionnaire.

# This implements Metasurvey(type) specific model methods.We implement the metasurvey 
# specific functionality of associating the current metasurvey to "selected" surveys.
 
# These methods are invoked when called by any activeRecord object(row) of 
# questionnaires table with type 'Metasurvey'

class Metasurvey < Questionnaire 
    # for doc on why we do it this way, 
    # see http://blog.hasmanythrough.com/2007/1/15/basic-rails-association-cardinality
    
    # can these be inherited too?
    validates_presence_of :name
    validates_numericality_of :max_question_score
    validates_numericality_of :min_question_score
   
      def specific_edit (role,instructor)
        @surveys = Survey.find_by_sql "select * from Questionnaires where type='Survey' AND (#{role} > (select r.id from roles r, users u where r.id=u.role_id and instructor_id = u.id) OR private=0 OR instructor_id = #{instructor} )"
        @surveys
      end
      
      def update_mapping(questionnaire_id,selected)
         @rubric = Metasurvey.find(questionnaire_id)
        selected.each do |select|
            @sur= Questionnaire.find_by_name(select)
            @sur.survey_mapping_id=questionnaire_id;
            @sur.save
        end  
      end
end
