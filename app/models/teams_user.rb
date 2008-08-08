class TeamsUser < ActiveRecord::Base      
  def name
    User.find(self.user_id).name
  end
  
  def delete
    TeamUserNode.find_by_node_object_id(self.id)
    self.destroy
  end
end