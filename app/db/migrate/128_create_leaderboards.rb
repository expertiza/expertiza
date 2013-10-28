 class CreateLeaderboards < ActiveRecord::Migration
   def self.up
     create_table :leaderboards do |t|
       t.column :questionnaire_type_id, :integer
       t.column :name, :string
       t.column :qtype, :string
       
     end
     Leaderboard.create( :questionnaire_type_id => 0, :name => 'Overall Grade', :qtype => '0') #Overall grade (not tied to questionnaire_type)
     Leaderboard.create( :questionnaire_type_id => 1, :name => 'Submitted Work', :qtype => 'ReviewQuestionnaire' ) #Review
     Leaderboard.create( :questionnaire_type_id => 5, :name => 'Reviewed by Author', :qtype => 'AuthorFeedbackQuestionnaire') #Author Feedback
     Leaderboard.create( :questionnaire_type_id => 6, :name => 'Reviewer', :qtype => 'MetareviewQuestionnaire') #Metareview
     Leaderboard.create( :questionnaire_type_id => 7, :name => 'Reviewed by Teammates', :qtype => 'TeammateReviewQuestionnaire') #Teammate Review
   end
 
   def self.down
     drop_table :leaderboards
   end
 end
