class AuditTrials < ActiveRecord::Migration
  def self.up
  create_table "audit_trials", :force => true do |t|
    t.column "suggestion_id", :integer
    t.column "unityID", :string
    t.column "title", :text
    t.column "description", :text
    t.column "status", :string
    t.column "is_comment", :boolean, :default => false
    t.timestamps
    

    
  end

    # suggestion_id is a foreign key in this table
    # suggestion_id is a foreign key in this table, index is created for the same
    # On delete Cascade will truncate the child table automatically when a parent table is truncated. 
  add_index "audit_trials", ["suggestion_id"], :name => "fk_audit_trials_suggestions"
 
  execute "alter table audit_trials
             add constraint fk_audit_trials_suggestions
             foreign key (suggestion_id) references suggestions(id) ON DELETE CASCADE"   
  end

  def self.down
    drop_table "audit_trials"
  end
end
