class UpdateMenus < ActiveRecord::Migration
  def self.up
    site_controller = SiteController.find_by_name('tree_display')
    
    drill_action = ControllerAction.find_or_create_by_name('drill')
    drill_action.site_controller_id = site_controller.id
    drill_action.save   
    
    questionnaires_action = ControllerAction.find_or_create_by_name('goto_questionnaires')
    questionnaires_action.site_controller_id = site_controller.id
    questionnaires_action.save
    
    author_feedbacks_action = ControllerAction.find_or_create_by_name('goto_author_feedbacks')
    author_feedbacks_action.site_controller_id = site_controller.id
    author_feedbacks_action.save
    
    review_rubrics_action = ControllerAction.find_or_create_by_name('goto_review_rubrics')
    review_rubrics_action.site_controller_id = site_controller.id
    review_rubrics_action.save
    
    global_survey_action = ControllerAction.find_or_create_by_name('goto_global_survey')
    global_survey_action.site_controller_id = site_controller.id
    global_survey_action.save    
    
    surveys_action = ControllerAction.find_or_create_by_name('goto_surveys')
    surveys_action.site_controller_id = site_controller.id
    surveys_action.save
    
    course_evaluations_action = ControllerAction.find_or_create_by_name('goto_course_evaluations')
    course_evaluations_action.site_controller_id = site_controller.id
    course_evaluations_action.save
    
    courses_action = ControllerAction.find_or_create_by_name('goto_courses')
    courses_action.site_controller_id = site_controller.id
    courses_action.save
    
    assignments_action = ControllerAction.find_or_create_by_name('goto_assignments')
    assignments_action.site_controller_id = site_controller.id
    assignments_action.save    
    
    MenuItem.find(:all, :conditions => ['parent_id is null and seq >= 3']).each{
      |item|
      item.seq += 1
      item.save
    }
    
    
    manage_item = MenuItem.find_or_create_by_name('manage instructor content')    
    manage_item.label = 'Manage...'
    manage_item.seq = 3
    manage_item.controller_action_id = drill_action.id
    manage_item.save
    
    users_item = MenuItem.find_by_label('Users')
    users_item.name = 'manage/users'
    users_item.parent_id = manage_item.id
    users_item.seq = 1
    users_item.save
    
    item = MenuItem.create(:name => 'manage/questionnaires', :label => 'Questionnaires', :parent_id => manage_item.id, :seq => 2, :controller_action_id => questionnaires_action.id)
    MenuItem.create(:name => 'manage/questionnaires/review rubrics', :label => 'Review rubrics', :parent_id => item.id, :seq => 1, :controller_action_id => review_rubrics_action.id)
    MenuItem.create(:name => 'manage/questionnaires/author feedbacks', :label => 'Author feedbacks', :parent_id => item.id, :seq => 2, :controller_action_id => author_feedbacks_action.id)
    MenuItem.create(:name => 'manage/questionnaires/global survey', :label => 'Global survey', :parent_id => item.id, :seq => 3, :controller_action_id => global_survey_action.id)
    MenuItem.create(:name => 'manage/questionnaires/surveys', :label => 'Surveys', :parent_id => item.id, :seq => 4, :controller_action_id => surveys_action.id)
    MenuItem.create(:name => 'manage/questionnaires/course evaluations', :label => 'Course evaluations', :parent_id => item.id, :seq => 5, :controller_action_id => surveys_action.id)
    
    MenuItem.create(:name => 'manage/courses', :label => 'Courses', :parent_id => manage_item.id, :seq => 3, :controller_action_id => courses_action.id)
    MenuItem.create(:name => 'manage/assignments', :label => 'Assignments', :parent_id => manage_item.id, :seq => 4, :controller_action_id => assignments_action.id)
    
    impersonate_item = MenuItem.find_by_label('Impersonate User')
    impersonate_item.parent_id = manage_item.id
    impersonate_item.seq = 5
    impersonate_item.save
    
    admin_item = MenuItem.find_by_label('Administration')
    admin_item.controller_action_id = nil
    content_page = ContentPage.find_by_name('site_admin')
    content_page.permission_id = Permission.find_by_name('administer goldberg')
    content_page.save
    admin_item.content_page_id = content_page.id
    admin_item.save
    
    show_item = MenuItem.create(:name => 'show', :label => 'Show...', :parent_id => admin_item.id, :seq => 2, :controller_action_id => users_item.controller_action_id)
    item = MenuItem.find_by_name('List Institutions')
    item.name = 'show/institutions'
    item.parent_id = show_item.id
    item.seq = 1
    item.save
    
    item = MenuItem.find_by_name('List Super-Administrators')
    item.name = 'show/super-administrators'
    item.parent_id = show_item.id
    item.seq = 2
    item.save
    
    item = MenuItem.find_by_name('List Administrators')
    item.name = 'show/administrators'
    item.parent_id = show_item.id
    item.seq = 3
    item.save    
   
    item = MenuItem.find_by_name('List Instructors')
    item.name = 'show/instructors'
    item.parent_id = show_item.id
    item.seq = 4
    item.save    
    
    Role.rebuild_cache 
  end

  def self.down
  end
end
