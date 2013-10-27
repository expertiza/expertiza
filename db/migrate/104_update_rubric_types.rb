class UpdateRubricTypes < ActiveRecord::Migration
  def self.up
    metareview_type = ActiveRecord::Base.connection.select_one("select * from `questionnaire_types` where name = 'Metareview'")
    pnode = QuestionnaireTypeNode.find_by_node_object_id(metareview_type["id"])
    questionnaires = Questionnaire.find(:all, :conditions => ['id in (6,16,43,91)'])
    questionnaires.each{
      | questionnaire | 
      questionnaire.type_id = metareview_type["id"]
      node = QuestionnaireNode.find_by_node_object_id(questionnaire.id)
      node.parent_id = pnode.id
      node.save
      questionnaire.save
      questionnaire.questions.each{
         |question|
         scores = Score.find(:all, :conditions => ['question_id = ?',question.id])
         scores.each{
            | score | 
            metareview = ActiveRecord::Base.connection.select_one("select * from `review_of_reviews where id = #{score.instance_id}")
            if metareview != nil
              score.update_attribute('questionnaire_type_id',metareview_type["id"])              
            end
         }
       }
    }     
  end

  def self.down
  end
end
