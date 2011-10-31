class DropReviewAndMappingStrategies < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `assignments` 
             DROP FOREIGN KEY fk_assignments_mapping_strategies"  
    execute "ALTER TABLE `assignments` 
             DROP FOREIGN KEY fk_assignments_review_strategies"  
    remove_column :assignments, :review_strategy_id
    remove_column :assignments, :mapping_strategy_id
    drop_table :review_strategies
    drop_table :mapping_strategies
  end

  def self.down
    create_table :review_strategies do |t|
      t.string :name
    end

    create_table :mapping_strategies do |t|
      t.string :name
    end

    add_column :assignments, :review_strategy_id, :integer
    add_column :assignments, :mapping_strategy_id, :integer

    execute "ALTER TABLE `assignments` 
             ADD CONSTRAINT `fk_assignments_review_strategies`
             FOREIGN KEY (review_strategy_id) references review_strategies(id)"  
             
    execute "ALTER TABLE `assignments` 
             ADD CONSTRAINT `fk_assignments_mapping_strategies`
             FOREIGN KEY (mapping_strategy_id) references mapping_strategies(id)"  
  end
end
