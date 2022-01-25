class RemoveSurveyRelatedMenuItems < ActiveRecord::Migration
  def change
    menu_items = []
    menu_items << MenuItem.find(30) # Course Evaluations
    menu_items << MenuItem.find(35) # Survey Deployment
    menu_items << MenuItem.find(36) # Statistical Test
    menu_items << MenuItem.find(41) # Global Surveys
    menu_items << MenuItem.find(42) # Surveys
    menu_items << MenuItem.find(43) # Course Evaluations
    menu_items.each do |menu_item|
      menu_item.destroy
    end
  end
end
