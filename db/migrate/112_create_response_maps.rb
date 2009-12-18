class CreateResponseMaps < ActiveRecord::Migration
  def self.up
    create_table :response_maps do |t|
      t.column :reviewed_object_id, :integer, :null => false
      t.column :reviewer_id,        :integer, :null => false
      t.column :reviewee_id,        :integer, :null => false
      t.column :type,               :string,  :null => false     
    end     
    
    # reviewee can't be constrained since it maps to either a participant or a team
    # a better design might allow for teams to be and have participants.
    
    execute 'ALTER TABLE `response_maps`
             ADD CONSTRAINT fk_response_map_reviewer
             FOREIGN KEY (reviewer_id) REFERENCES participants(id)'      
    
    create_table :responses do |t|
      t.column :map_id, :integer, :null => false
      t.column :additional_comment, :string, :null => true
      t.column :created_at, :datetime, :null => true
      t.column :updated_at, :datetime, :null => true
    end
    
    execute 'ALTER TABLE `responses`
             ADD CONSTRAINT fk_response_response_map
             FOREIGN KEY (map_id) REFERENCES response_maps(id)'    
    
    add_column :scores, :response_id, :integer, :null => true
    
    execute 'ALTER TABLE `scores`
             ADD CONSTRAINT fk_score_response
             FOREIGN KEY (response_id) REFERENCES responses(id)'              
   
    ReviewOfReviewMapping.find(:all).each{
       | map | 
       create_response_map(map,"ReviewOfReview","MetareviewResponseMap", "MetareviewQuestionnaire")       
    }
    
    FeedbackMapping.find(:all).each{
       | map | 
       create_response_map(map,"ReviewFeedback","FeedbackResponseMap", "AuthorFeedbackQuestionnaire")
    }  
    
    TeammateReviewMapping.find(:all).each{
       | map | 
       create_response_map(map,"TeammateReview","TeammateReviewResponseMap", "TeammateReviewQuestionnaire")        
    }     
   
    # create response mappings as associate to a given review object
    ReviewMapping.find(:all).each{
       | map | 
       review = Review.find_by_mapping_id(map.id)
       if map.instance_of? ParticipantReviewMapping
          map_type = "ParticipantReviewResponseMap"
       else
          map_type = "TeamReviewResponseMap"
       end
       rmap, response = create_response_map(map,"Review",map_type, "ReviewQuestionnaire")
       
       MetareviewResponseMap.find_all_by_reviewed_object_id(map.id).each{
         | metamap |
         if rmap != nil
           metamap.update_attribute('reviewed_object_id',rmap.id)
         else
          cleanup(metamap)         
         end   
       }
       
       if review != nil
       FeedbackResponseMap.find_all_by_reviewed_object_id(review.id).each{
         | fmap |
         if response != nil
          fmap.update_attribute('reviewed_object_id',response.id)
         else
          cleanup(fmap)
         end
       }  
       end    
    }
    
    Score.delete_all("response_id is null")   
     
    remove_column :scores, :instance_id
     
    drop_table :review_of_reviews    
    drop_table :review_of_review_mappings
    drop_table :review_feedbacks
    drop_table :feedback_mappings
    drop_table :teammate_reviews
    drop_table :teammate_review_mappings    
    drop_table :reviews
    drop_table :review_mappings

  end
  
  def self.cleanup(map)
    response = Response.find_by_map_id(map.id)    
    if response != nil       
       Score.delete_all(["instance_id = ?", response.id])       
       response.destroy
    end
    map.destroy    
  end
  
  def self.create_response_map(map, review_type, map_type, questionnaire_type)
    response = nil
    rmap = nil 
   
    today = Time.now             
    oldest_allowed_time = Time.local(today.year - 1,today.month,today.day,0,0,0)    
    
       review = Object.const_get(review_type).find_by_mapping_id(map.id)       
       if review.nil? and (map.assignment.created_at.nil? or map.assignment.created_at < oldest_allowed_time)
         puts "IGNORE: #{map.type} #{map.id} is at least a year old and has no review associated with it."         
       else       
        rmap = Object.const_get(map_type).create(
                  :reviewed_object_id => map.reviewed_object_id,
                  :reviewer_id => map.reviewer_id,
                  :reviewee_id => map.reviewee_id)                 
        if review != nil     
          questionnaire = map.assignment.questionnaires.find_by_type(questionnaire_type)          
          if questionnaire != nil
            response = create_response(review, rmap, questionnaire.questions)
          end
        end
      end
    return rmap, response
  end
  
  def self.create_response(review, response_map, questions)      
      response = Response.create(:map_id => response_map.id, :additional_comment => review.additional_comment)
      Response.record_timestamps = false
      response.update_attribute('created_at',review.created_at)
      response.update_attribute('updated_at',review.updated_at)            
      Response.record_timestamps = true
      score_found = false      
      questions.each{
        | question |
        score = Score.find_by_instance_id_and_question_id(review.id, question.id) 
        if score != nil
          score_found = true
          score.update_attribute('response_id',response.id)
        end
      }      
      if !score_found
        response.destroy        
      end
      return response
  end

  def self.down    
    begin
      execute "ALTER TABLE `scores` 
               DROP FOREIGN KEY `fk_score_response`"
    rescue
    end
    
    begin
      execute "ALTER TABLE `scores` 
               DROP INDEX `fk_score_response`"
    rescue
    end
   
    remove_column :scores, :response_id
  
    drop_table :responses
    drop_table :response_maps    
  end
end
