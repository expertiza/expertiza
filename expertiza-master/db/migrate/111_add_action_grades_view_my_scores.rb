class AddActionGradesViewMyScores < ActiveRecord::Migration
  def self.up
    perm = Permission.find_by_name("do assignments")
    controller = SiteController.find_by_name("grades")
    ControllerAction.create(:site_controller_id => controller.id, :name => "view_my_scores", :permission_id => perm.id) 
    
    Role.rebuild_cache     
  end

  def self.down
  end
end
