class CreateReviewFiles < ActiveRecord::Migration
  def self.up
    create_table :review_files do |t|
      t.string :filepath
      t.integer :author_participant_id
      t.integer :version_number

      t.timestamps
    end

    permission = Permission.find_by_name("do assignments")

    site_controller = SiteController.find_or_create_by(name: "review_files")
    if site_controller
      site_controller.permission_id = permission.id
      site_controller.save

      action = ControllerAction.find_or_create_by(name: "show_code_file")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id
        action.save
      end

      action = ControllerAction.find_or_create_by(name: "show_code_file_diff")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id
        action.save
      end

      action = ControllerAction.find_or_create_by(name: "show_all_submitted_files")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id
        action.save
      end

      action = ControllerAction.find_or_create_by(name: "submit_comment")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id
        action.save
      end

      action = ControllerAction.find_or_create_by(name: "submit_review_file")
      if action != nil
        action.site_controller_id = site_controller.id
        action.permission_id = permission.id
        action.save
      end

    end
    Role.rebuild_cache

  end

  def self.down
    drop_table :review_files
  end
end
