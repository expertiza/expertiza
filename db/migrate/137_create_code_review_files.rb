class CreateCodeReviewFiles < ActiveRecord::Migration
  def self.up
    create_table :code_review_files do |t|
      t.text :contents
      t.string :name
      t.integer :participantid
      t.timestamps
    end

    permission = Permission.find_by_name("do assignments")
    
    site_controller = SiteController.find_or_create_by_name("code_review_files")
    if site_controller
      site_controller.permission_id = permission.id
      site_controller.save

      action = ControllerAction.find_or_create_by_name("create_code_review_file")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id   
        action.save
      end      
      action = ControllerAction.find_or_create_by_name("show_code_review_file")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id   
        action.save
      end      
      action = ControllerAction.find_or_create_by_name("delete_code_review_file")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id   
        action.save
      end      
      action = ControllerAction.find_or_create_by_name("update_code_review_file")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id   
        action.save
      end      
      action = ControllerAction.find_or_create_by_name("rename_code_review_file")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id   
        action.save
      end      

      action = ControllerAction.find_or_create_by_name("update_code_review_file_comment")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id   
        action.save
      end      
      action = ControllerAction.find_or_create_by_name("create_code_review_file_comment")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id   
        action.save
      end      
      action = ControllerAction.find_or_create_by_name("delete_code_review_file_comment")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id   
        action.save
      end      
    end

    Role.rebuild_cache 
  end

  def self.down
    drop_table :code_review_files
  end
end
