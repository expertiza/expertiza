class AddSelfIntroductionToRequestedUser < ActiveRecord::Migration
   def change
     add_column :account_requests, :self_introduction, :text
   end
 end