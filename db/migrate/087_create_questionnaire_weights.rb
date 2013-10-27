class CreateQuestionnaireWeights < ActiveRecord::Migration
  def self.up
    create_table :questionnaire_weights do |t|
      t.column :assignment_id, :integer, :null => false
      t.column :questionnaire_id, :integer, :null => false
      t.column :weight, :float, :null => false, :default => 0
      t.column :type, :string
    end
    
    Assignment.find(:all).each{
      |assignment|
      if assignment.review_questionnaire_id != nil && assignment.review_questionnaire_id != 0
        qweight = ReviewWeight.create(
          :assignment_id => assignment.id,
          :questionnaire_id => assignment.review_questionnaire_id            
        );
        if assignment.review_weight != nil and assignment.review_weight > 0
          qweight.weight = assignment.review_weight
        else
          qweight.weight = 100
        end     
        qweight.save
      end
      if assignment.review_of_review_questionnaire_id != nil && assignment.review_of_review_questionnaire_id != 0
        mweight = MetareviewWeight.create(
          :assignment_id => assignment.id,
          :questionnaire_id => assignment.review_of_review_questionnaire_id         
        );
        if assignment.review_weight != nil
          mweight.weight = 100 - assignment.review_weight          
        else
          mweight.weight = 0
        end   
        mweight.save
      end
      if assignment.author_feedback_questionnaire_id != nil && assignment.author_feedback_questionnaire_id != 0
        AuthorFeedbackWeight.create(
          :assignment_id => assignment.id,
          :questionnaire_id => assignment.author_feedback_questionnaire_id
        );
      end
      if (assignment.teammate_review_questionnaire_id)
        TeammateReviewWeight.create(
          :assignment_id => assignment.id,
          :questionnaire_id => assignment.teammate_review_questionnaire_id && assignment.teammate_review_questionnaire_id != 0
        );
      end
    }    
    remove_column :assignments, :review_weight
  end

  def self.down
    add_column :assignments, :review_weight,:float
    ReviewWeight.find(:all).each{
      |item|
      assignment = Assignment.find(item.assignment_id)
      assignment.review_weight = item.weight
      assignment.save      
    }
    drop_table :questionnaire_weights
  end
end
