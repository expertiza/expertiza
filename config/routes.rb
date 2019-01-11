Expertiza::Application.routes.draw do
  ###
  # Please insert new routes alphabetically!
  ###
  resources :admin, only: [] do
    collection do
      get :list_super_administrators
      get :list_administrators
      get :list_instructors
      post :create_instructor
      get :remove_instructor
      post :remove_instructor
      get :show_instructor
    end
  end

  resources :advertise_for_partner, only: %i[new create edit update] do
    collection do
      get :remove
      post ':id', action: :update
    end
  end

  resources :advice, only: [] do
    collection do
      post :save_advice
    end
  end

  resources :answer

  resources :answer_tags, only: [:index] do
    collection do
      post :create_edit
    end
  end

  resources :assessment360, only: [] do
    collection do
      get :course_student_grade_summary
      get :all_students_all_reviews
    end
  end

  resources :assignments, except: [:destroy] do
    collection do
      get :associate_assignment_with_course
      get :copy
      get :toggle_access
      get :delayed_mailer
      get :list_submissions
      get :delete_delayed_mailer
      get :remove_assignment_from_course
    end
  end

  resources :badges, only: %i[new create] do
    collection do
      get :redirect_to_assignment
    end
  end

  resources :bookmarks, except: %i[index show] do
    collection do
      get :list
      post :save_bookmark_rating_score
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
      get :list
      post ':id', action: :update
      get :new_for
    end
  end

  resources :course, only: %i[new create edit update] do
    collection do
      get :toggle_access
      get :copy
      get :view_teaching_assistants
      post :add_ta
      get :auto_complete_for_user_name
      post :remove_ta
    end
  end

  resources :eula, only: [] do
    collection do
      get :accept
      get :decline
      get :display
    end
  end

  resources :export_file, only: [] do
    collection do
      get :start
      get :export
      post :export
      post :exportdetails
    end
  end

  resources :grades, only: %i[edit update] do
    collection do
      get :view
      get :view_team
      get :view_reviewer
      get :view_my_scores
      get :instructor_review
      post :remove_hyperlink
      post :save_grade_and_comment_for_submission
    end
  end

  resources :impersonate, only: [] do
    collection do
      get :start
      post :impersonate
    end
  end

  resources :import_file, only: [] do
    collection do
      get :start
      get :show
      get :import
      post :show
      post :import
    end
  end

resources :institution, except: [:destroy] do
    collection do
      get :list
      post ':id', action: :update
    end
  end

  resources :invitations, only: %i[new create] do
    collection do
      get :cancel
      get :accept
      get :decline
    end
  end

  resources :join_team_requests do
    collection do
      post :decline
    end
  end

  resources :late_policies
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

  resources :notifications

  resources :participants, only: [:destroy] do
    collection do
      get :add
      post :add
      get :auto_complete_for_user_name
      get :delete_assignment_participant
      get :list
      get :change_handle
      get :inherit
      get :bequeath_all
      get :inherit
      get :bequeath_all
      post :update_authorizations
      post :update_duties
      post :change_handle
      get :view_publishing_rights
    end
  end

  resources :password_retrieval, only: [] do
    collection do
      get :forgotten
      get :reset_password
      post :send_password
      post :update_password
    end
  end

  resources :profile, only: %i[edit update]

  resources :publishing, only: [] do
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

  resources :questionnaires, only: %i[new create edit update] do
    collection do
      get :copy
      get :new_quiz
      get :select_questionnaire_type
      post :select_questionnaire_type
      get :toggle_access
      get :view
      post :create_quiz_questionnaire
      post :update_quiz
      post :add_new_questions
      post :save_all_questions
    end
  end

  resources :author_feedback_questionnaires, controller: :questionnaires
  resources :review_questionnaires, controller: :questionnaires
  resources :metareview_questionnaires, controller: :questionnaires
  resources :teammate_review_questionnaires, controller: :questionnaires
  resources :survey_questionnaires, controller: :questionnaires
  resources :assignment_survey_questionnaires, controller: :questionnaires
  resources :global_survey_questionnaires, controller: :questionnaires
  resources :course_survey_questionnaires, controller: :questionnaires
  resources :bookmark_rating_questionnaires, controller: :questionnaires

  resources :questions do
    collection do
      get :types
    end
  end

  resources :reputation_web_service, only: [] do
    collection do
      get :client
      post :send_post_request
    end
  end

  resources :response, only: %i[new create edit update] do
    collection do
      get :new_feedback
      get :view
      get :remove_hyperlink
      get :save
      get :redirect
      get :show_calibration_results_for_student
      post :custom_create
      get :pending_surveys
      get :json
    end
  end

  resources :review_mapping, only: [] do
    collection do
      post :add_metareviewer
      get :add_reviewer
      post :add_reviewer
      post :add_self_reviewer
      get :add_self_reviewer
      get :add_user_to_assignment
      get :auto_complete_for_user_name
      get :delete_all_metareviewers
      get :delete_outstanding_reviewers
      get :delete_metareviewer
      get :delete_reviewer
      get :distribution
      get :list_mappings
      get :response_report
      post :response_report
      get :select_metareviewer
      get :select_reviewer
      get :select_mapping
      post :assign_quiz_dynamically
      get :assign_reviewer_dynamically
      post :assign_reviewer_dynamically
      get :assign_metareviewer_dynamically
      post :assign_metareviewer_dynamically
      post :automatic_review_mapping
      post :automatic_review_mapping_staggered
      # E1600
      post :start_self_review
      post :save_grade_and_comment_for_reviewer
      get :unsubmit_review
    end
  end

  resources :roles do
    collection do
      get :list
      post ':id', action: :update
    end
  end

  resources :sign_up_sheet, except: %i[index show] do
    collection do
      get :signup
      get :delete_signup
      get :add_signup_topics
      get :add_signup_topics_staggered
      get :delete_signup
      get :list
      get :signup_topics
      get :signup
      get :sign_up
      get :team_details
      get :intelligent_sign_up
      get :intelligent_save
      get :signup_as_instructor
      post :signup_as_instructor_action
      post :set_priority
      post :save_topic_deadlines
    end
  end

  resources :site_controllers do
    collection do
      get :list
      get :new_called
    end
  end

  resources :student_quizzes, only: [:index] do
    collection do
      post :student_quizzes
      post :record_response
      get :finished_quiz
      get :take_quiz
      get :review_questions
    end
  end

  resources :student_review, only: [] do
    collection do
      get :list
    end
  end

  resources :student_task, only: [] do
    collection do
      get :list
      get :view
      get '/*other', to: redirect('/student_task/list')
    end
  end

  resources :student_teams, only: %i[create edit update] do
    collection do
      get :view
      get :remove_participant
      get :auto_complete_for_user_name
    end
  end

  resources :submitted_content, only: [:edit] do
    collection do
      get :download
      get :folder_action
      get :remove_hyperlink
      post :remove_hyperlink
      get :submit_file
      post :submit_file
      post :folder_action
      post :submit_hyperlink
      get :submit_hyperlink
      get :view
    end
  end

  resources :submission_records, only: [:index]

  resources :suggestion, only: %i[show new create] do
    collection do
      get :list
      post :submit
      post :student_submit
      post :update_suggestion
    end
  end

  resources :survey_deployment, only: %i[new create] do
    collection do
      get :list
      get :reminder_thread
    end
  end

  resources :system_settings do
    collection do
      get :list
    end
  end

  resources :teams, only: %i[new create edit update] do
    collection do
      get :list
      # post ':id', action: :create_teams
      post :create_teams
      post :inherit
    end
  end

  resources :teams_users, only: %i[new create] do
    collection do
      post :list
    end
  end

  resources :tag_prompts, except: %i[new edit]
  resources :track_notifications, only: [:index]

  resources :tree_display, only: [] do
    collection do
      get :action
      post :list
      post :children_node_ng
      post :children_node_2_ng
      post :bridge_to_is_available
      get :session_last_open_tab
      get :set_session_last_open_tab
    end
  end

  resources :users, constraints: {id: /\d+/} do
    collection do
      get :list
      post :list
      get :list_pending_requested
      post ':id', action: :update
      get :show_selection
      get :auto_complete_for_user_name
      get :set_anonymized_view
      get :keys
      post :create_requested_user_record
      post :create_approved_user
    end
  end

  resources :user_pastebins

  resources :versions, only: %i[index show] do
    collection do
      get :search
    end
  end

  root to: 'content_pages#view', page_name: 'home'
  post :login, to: 'auth#login'
  post :logout, to: 'auth#logout'
  get 'auth/:provider/callback', to: 'auth#google_login'
  get 'auth/failure', to: 'content_pages#view'
  get '/auth/*path', to: redirect('/')
  get '/menu/*name', controller: :menu_items, action: :link
  get ':page_name', controller: :content_pages, action: :view, method: :get
  post 'impersonate/impersonate', to: 'impersonate#impersonate'
  post '/plagiarism_checker_results/:id' => 'plagiarism_checker_comparison#save_results'
  get 'instructions/home'
  get 'response/', to: 'response#saving'
  get ':controller/service.wsdl', action: 'wsdl'
  get 'password_edit/check_reset_url', controller: :password_retrieval, action: :check_reset_url
  get ':controller(/:action(/:id))(.:format)'
  match '*path' => 'content_pages#view', :via => %i[get post] unless Rails.env.development?
end
