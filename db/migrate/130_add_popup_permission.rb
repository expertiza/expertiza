class AddPopupPermission < ActiveRecord::Migration
  def self.up
    sc = SiteController.new
    sc.name = "popup"
    sc.permission_id = 10
  
  end

 def self.down
  sc =  SiteController.find_by_name("popup")
  sc.delete
 end
end
