class AddPopupPermission < ActiveRecord::Migration
  def self.up
    sc = SiteController.new
    sc.name = "popups"
    sc.permission_id = 10
  
  end

 def self.down
  sc =  SiteController.find_by_name("popups")
  sc.delete
 end
end
