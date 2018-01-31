class AddSelfIntroductionToRequestedUser < ActiveRecord::Migration
   def change
     add_column :requested_users, :self_introduction, :text
   end
 end