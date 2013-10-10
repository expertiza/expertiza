Expertiza::Application.routes.draw do |map|

  resources :admin do
    collection do
      get :list_super_administrators
      get :list_administrators
      get :list_instructors
      get :new_administrator
      get :new_instructor
      post :create_instructor
      get :remove_instructor
      post :remove_instructor
      get :show_instructor
    end
  end

  resources :advertise_for_partner do
    collection do
      get :edit
      get :remove
      post ':id', action: :update
    end
  end

  resources :assessment360 do
    collection do
      get :one_course_all_assignments
    end
  end

  resources :assignments do
    collection do
      get :associate_assignment_with_course
      get :copy
      get :toggle_access
      post :remove_assignment_from_course
    end
  end

  resources :auth do
    collection do
      post :login
      post :logout
    end
  end

  resources :author_feedback_questionnaires, controller: 'questionnaires'

  resources :content_pages do
    collection do
      get :list
      get ':page_name', action: :view
    end
  end

  resources :controller_actions do
    collection do
      get 'list'
      post ':id', action: :update
      get 'new_for'
    end
  end

  resources :course do
    collection do
      post :delete
      post :toggle_access
      get :copy
      get :view_teaching_assistants
      post :add_ta
      get :auto_complete_for_user_name
      post :remove_ta
    end
  end

  resources :course_evaluation do
    collection do
      get :list
    end
  end

  resources :eula do
    collection do
      get :accept
      get :decline
      get :display
    end
  end

  resources :export_file do
    collection do
      get :start
    end
  end

  resources :grades do
    collection do
      get :view
      get :view_my_scores
      get :instructor_review
      get :remove_hyperlink
      get :conflict_notification
    end
  end

  resources :impersonate do
    collection do
      get :start
      post :impersonate
    end
  end

  resources :import_file do
    collection do
      get :start
      get :import
    end
  end

  resources :institutions

  resources :invitation

  resources :join_team_requests

  resources :leaderboard, constraints: { id: /\d+/ } do
    collection do
      get :index
    end
  end
  match 'leaderboard/index', controller: :leaderboard, action: :index

  resources :markup_styles

  resources :menu_items do
    collection do
      get :move_down
      get :move_up
      get :new_for
      get :link
      get :list
    end
  end

  resources :participants do
    collection do
      get :add
      post :add
      get :auto_complete_for_user_name
      get :list
      get :change_handle
      post :delete
    end
  end

  resources :password_retrieval do
    collection do
      get :forgotten
      post :send_password
    end
  end

  resources :permissions, constraints: { id: /\d+/ } do
    collection do
      get :list
      get ':id', action: :show
      post ':id', action: :update
      delete ':id', action: :destroy
    end
  end

  resources :profile do
    collection do
      get :edit
    end
  end

  resources :publishing do
    collection do
      get :view
      post :update_publish_permissions
      post :set_publish_permission
      get :grant
      get :grant_with_private_key
      post :grant_with_private_key
      get :set_publish_permission
    end
  end

  resources :questionnaires do
    collection do
      post :toggle_access
      get :copy
      post :select_questionnaire_type
    end
  end
  resources :review_questionnaires, controller: :questionnaires
  resources :metareview_questionnaires, controller: :questionnaires
  resources :teammate_review_questionnaires, controller: :questionnaires
  resources :survey_questionnaires, controller: :questionnaires
  resources :global_survey_questionnaires, controller: :questionnaires
  resources :course_evaluation_questionnaires, controller: :questionnaires

  resources :response do
    collection do
      get :new_feedback
      get :view
      post :delete
    end
  end

  resources :review_mapping do
    collection do
      get :list_mappings
      get :review_report
    end
  end

  resources :review_files do
    collection do
      get :show_all_submitted_files
    end
  end

  resources :roles do
    collection do
      get :list
      post ':id', action: :update
    end
  end

  resources :roles_permissions do
    collection do
      get :new_permission_for_role
    end
  end

  resources :sign_up_sheet do
    collection do
      get :add_signup_topics
      get :add_signup_topics_staggered
      get :signup_topics
      get :view_publishing_rights
    end
  end

  resources :site_controllers do
    collection do
      get 'list'
      get 'new_called'
    end
  end

  resources :statistics do
    collection do
      get :list_surveys
      get :list
      get :view_responses
    end
  end

  resources :student_review do
    collection do
      get :list
    end
  end

  resources :student_task do
    collection do
      get :list
      get :view
    end
  end

  resources :student_team do
    collection do
      get :view
      get :edit
      get :leave
      get :auto_complete_for_user_name
    end
  end

  resources :submitted_content do
    collection do
      get :view
      get :edit
    end
  end

  resources :suggestion do
    collection do
      get :list
    end
  end

  resources :survey do
    collection do
      get :assign
    end
  end

  resources :survey_deployment do
    collection do
      get :list
      get :delete
      get :reminder_thread
    end
  end

  resources :survey_response do
    collection do
      get :view_responses
    end
  end

  resources :system_settings do
    collection do
      get :list
    end
  end

  resources :teams do
    collection do
      get :list
    end
  end

  resources :tree_display do
    collection do
      get ':action'
      post 'list'
    end
  end

  resources :users, constraints: { id: /\d+/ } do
    collection do
      get :list
      post ':id', action: :update
      get :show_selection
      get :auto_complete_for_user_name
      get :keys
    end
  end

  match '/menu/*name', controller: :menu_items, action: :link
  match ':page_name', controller: :content_pages, action: :view, method: :get

  root to: 'content_pages#view', page_name: 'home'

  map.connect 'question/select_questionnaire_type', :controller => "questionnaire", :action => 'select_questionnaire_type'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
end
