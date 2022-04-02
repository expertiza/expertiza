class UpdateRubricTypes < ActiveRecord::Migration[4.2]
  def self.up
    metareview_type = ActiveRecord::Base.connection.select_one("select * from `questionnaire_types` where name = 'Metareview'")
    pnode = QuestionnaireTypeNode.find_by_node_object_id(metareview_type['id'])
    questionnaires = Questionnaire.where(['id in (6,16,43,91)'])
    questionnaires.each do |questionnaire|
      questionnaire.type_id = metareview_type['id']
      node = QuestionnaireNode.find_by_node_object_id(questionnaire.id)
      node.parent_id = pnode.id
      node.save
      questionnaire.save
      questionnaire.questions.each do |question|
        scores = Score.where(['question_id = ?', question.id])
        scores.each  do |score|
          metareview = ActiveRecord::Base.connection.select_one("select * from `review_of_reviews where id = #{score.instance_id}")
          unless metareview.nil?
            score.update_attribute('questionnaire_type_id', metareview_type['id'])
          end
        end
      end
    end
  end

  def self.down; end
end
