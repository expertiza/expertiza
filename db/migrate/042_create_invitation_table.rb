class CreateInvitationTable < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      # Note: Table name pluralized by convention.
      t.column :assignment_id, :integer
      t.column :from_id, :integer
      t.column :to_id, :integer
      t.column :reply_status, :char
    end
    
    add_column :assignments, :max_team_count, :boolean
    
    add_index "invitations", ["from_id"], :name => "fk_invitationfrom_users"

    execute "alter table invitations 
               add constraint fk_invitationfrom_users
               foreign key (from_id) references users(id)"
               
    add_index "invitations", ["to_id"], :name => "fk_invitationto_users"

    execute "alter table invitations 
               add constraint fk_invitationto_users
               foreign key (to_id) references users(id)"
  
    
     add_index "invitations", ["assignment_id"], :name => "fk_invitation_assignments"
     
     execute "alter table invitations
              add constraint fk_invitation_assignments
              foreign key (assignment_id) references assignments(id)"
  end

  def self.down
    drop_table :invitations
  end
end