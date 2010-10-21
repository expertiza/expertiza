class AllowHostedDocs < ActiveRecord::Migration
  def self.up
    add_column :assignments, :allow_hosted_docs, :bool, :null => true  
  end

  def self.down
    remove_column :assignments, :allow_hosted_docs
  end
end
