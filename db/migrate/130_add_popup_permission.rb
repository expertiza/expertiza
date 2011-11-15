<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
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
<<<<<<< HEAD
=======
=======
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
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
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
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
