Expertiza::Application.routes.draw do
  resources :bookmark_tags
  resources :books
  resources :bookmarks
  resources :join_team_requests

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
      get :set_questionnaire
      get :set_due_date
      get :delete_all_questionnaires
      get :delete_all_due_dates
    end
  end

  resources :auth do
    collection do
      post :login
      post :logout
    end
  end

  resources :author_feedback_questionnaires, controller: 'questionnaires'

  resources :bookmark do
    collection do
      get :manage_bookmarks, as: :manage
      get :view_bookmark, as: :view
      get :view_rating_rubrics, as: :rating
      get :add_rating_rubric_form, as: :rating2
      get :add_tag_bookmark
      get :create_tag_bookmark
      get :search_bookmarks
      get :view_bookmarks
      get :bookmarks_rate, as: :bookmark_rate
      get :view_rating_rubric
    end
  end

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
      get :export
      post :export
    end
  end

  resources :grades do
    collection do
      get :view
      get :view_my_scores
      get :view_my_scores_new
      get :instructor_review
      post :remove_hyperlink
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

  get '/import_file/import', controller: :import_file, action: :import

  resources :institutions

  resources :invitation do
    collection do
      get :cancel
      get :accept
      get :decline
    end
  end

  resources :join_team_requests do
    collection do
      get :decline
    end
  end

  resources 'late_policies'

  resources :leaderboard, constraints: {id: /\d+/} do
    collection do
      get :index
    end
  end

  get 'leaderboard/index', controller: :leaderboard, action: :index

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
      get :delete_assignment_participant
      get :list
      get :change_handle
      get :inherit
      get :bequeath_all
      post :delete
      get :inherit
      get :bequeath_all
    end
  end

  get '/participants/change_handle', controller: :participants, action: :change_handle

  resources :password_retrieval do
    collection do
      get :forgotten
      post :send_password
    end
  end

  resources :permissions, constraints: {id: /\d+/} do
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
      get :copy
      get :edit
      get :list
      post :list_questionnaires
      get :new_quiz
      post :select_questionnaire_type
      post :toggle_access
      get :view
    end
  end

  resources :review_questionnaires, controller: :questionnaires
  resources :metareview_questionnaires, controller: :questionnaires
  resources :teammate_review_questionnaires, controller: :questionnaires
  resources :survey_questionnaires, controller: :questionnaires
  resources :global_survey_questionnaires, controller: :questionnaires
  resources :course_evaluation_questionnaires, controller: :questionnaires
  resources :bookmarkrating_questionnaires, controller: :questionnaires



  resources :response do
    collection do
      get :new_feedback
      get :view
      post :delete
      get :remove_hyperlink
      get :saving
      get :redirection
    end
  end

  resources :review_mapping do
    collection do
      post :add_metareviewer
      get :add_reviewer
      post :add_reviewer
      post :add_self_reviewer
      get :add_self_reviewer
      get :add_user_to_assignment
      get :assign_metareviewer_dynamically
      get :assign_reviewer_dynamically
      post :assign_reviewer_dynamically
      get :auto_complete_for_user_name
      get :delete_all_metareviewers
      get :delete_all_reviewers
      get :delete_all_reviewers_and_metareviewers
      get :delete_metareviewer
      get :delete_reviewer
      get :distribution
      get :list_mappings
      get :review_report
      get :select_metareviewer
      get :select_reviewer
      get :select_mapping
      get :show_available_submissions
    end
  end

  resources :review_files do
    collection do
      get :show_all_submitted_files
      get :show_code_file
      get :show_code_file_diff
      get :get_comments
      get :submit_comment
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
      get :signup
      get :delete_signup
      get :add_signup_topics
      get :add_signup_topics_staggered
      get :delete_signup
      get :edit
      get :list
      get :signup_topics
      get :signup
      get :sign_up
      get :team_details
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
      get :download
      get :edit
      get :folder_action
      post :remove_hyperlink
      get :submit_file
      post :submit_hyperlink
      get :submit_hyperlink
      get :view
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
      post ':id', action: :update
    end
  end

  resources :tree_display do
    collection do
      get ':action'
      post 'list'
    end
  end

  resources :users, constraints: {id: /\d+/} do
    collection do
      get :list
      post :list
      post ':id', action: :update
      get :show_selection
      get :auto_complete_for_user_name
      get :keys
    end
  end

  resources :versions do
    collection do
      delete '', action: :destroy_all
    end
  end

  get '/users/show_selection', controller: :users, action: :show_selection
  get '/users/list', controller: :users, action: :list
  get '/menu/*name', controller: :menu_items, action: :link
  get ':page_name', controller: :content_pages, action: :view, method: :get
  get '/submitted_content/submit_hyperlink' => 'submitted_content#submit_hyperlink'

  root to: 'content_pages#view', page_name: 'home'

  get 'users/list', :to => 'users#list'

  get '/submitted_content/remove_hyperlink', :to => 'submitted_content#remove_hyperlink'
  get '/submitted_content/submit_hyperlink', :to => 'submitted_content#submit_hyperlink'
  get '/submitted_content/submit_file', :to => 'submitted_content#submit_file'
  get '/review_mapping/show_available_submissions', :to => 'review_mapping#show_available_submissions'
  get '/review_mapping/assign_reviewer_dynamically', :to => 'review_mapping#assign_reviewer_dynamically'
  get "/review_mapping/assign_metareviewer_dynamically", :to => 'review_mapping#assign_metareviewer_dynamically'
  get 'response/', :to => 'response#saving'

  get 'question/select_questionnaire_type', :controller => "questionnaire", :action => 'select_questionnaire_type'
  get ':controller/service.wsdl', :action => 'wsdl'

  get ':controller(/:action(/:id))(.:format)'
end
