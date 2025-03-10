class AddSelfIntroductionToRequestedUser < ActiveRecord::Migration[4.2]
   def change
     add_column :requested_users, :self_introduction, :text
   end
 end
