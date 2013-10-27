class AddNewMappingStrategy < ActiveRecord::Migration
  def self.up
    
    execute "INSERT INTO mapping_strategies (`id`, `name`) VALUES 
            (2, 'Dynamic, fewest extant reviews');"
            
    deadline_type = DeadlineType.find_by_name('review of review')
    deadline_type.name = 'metareview'
    deadline_type.save        
  end

  def self.down
  end
end
