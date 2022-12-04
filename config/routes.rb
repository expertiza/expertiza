Expertiza::Application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :admin, only: [] do
    collection do
      get :list_super_administrators
      get :list_administrators
      get :list_instructors
      post :create_instructor
      get :remove_instructor
      post :remove_instructor
      get :show_instructor
      get :show_administrator
      get :show_super_administrator
    end
  end

  resources :advertise_for_partner, only: %i[new create edit update] do
    collection do
      get :remove
      post ':id', action: :update
      get :update
      get :edit
    end
  end

  resources :advice, only: [] do
    collection do
      post :save_advice
      put :edit_advice
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
      get :assignment_grade_summary
      get :insure_existence_of
    end
  end

  resources :assignments, except: [:destroy] do
    collection do
      get :place_assignment_in_course
      get :copy
      get :toggle_access
      get :delayed_mailer
      get :list_submissions
      get :delete_delayed_mailer
      get :remove_assignment_from_course
      get :instant_flash
      patch :edit
      post :delete
    end
  end

  resources :assignment_questionnaire do
    collection do
      post :create
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

  resources :course, controller: 'courses', only: %i[new create edit update delete] do
    collection do
      get :toggle_access
      get :copy
      get :view_teaching_assistants
      post :add_ta
      get :auto_complete_for_user_name
      post :remove_ta
      post :edit
      post :set_course_fields
      post :delete
    end
  end

  resources :duties do
    collection do
      delete :delete
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
      post :export_advices
      put :exporttags
      post :exporttags
    end
  end

  put '/tags.csv', to: 'export_file#export_tags'

  resources :export_tags, only: [] do
    collection do
      put :exporttags
      post :exporttags
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
      post :delete
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
      get :index
      get :destroy
      get :show
    end
  end

  resources :late_policies
  resources :markup_styles do
    collection do
      get :list
    end
  end

  resources :menu_items do
    collection do
      get :move_down
      get :move_up
      get :new_for
      get :link
      get :list
    end
  end

  resources :lock do
    collection do
      post :release_lock
    end
  end

  resources :notifications do
    collection do
      get :run_get_notification
    end
  end

  resources :participants, only: [:destroy] do
    collection do
      get :add
      post :add
      get :auto_complete_for_user_name
      get :delete
      get :list
      get :change_handle
      get :inherit
      get :bequeath_all
      get :inherit
      get :bequeath_all
      post :update_authorizations
      post :change_handle
      get :view_copyright_grants
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

  resources :profile, only: [] do
    collection do
      get :edit
      post :update
      patch :update
    end
  end

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
      get :select_questionnaire_type
      post :select_questionnaire_type
      get :toggle_access
      get :view
      post :add_new_questions
      post :save_all_questions
      get :delete
      post :create_questionnaire
    end
  end

  resources :quiz do
    collection do
      get :view
    end
  end

  resources :quiz_questionnaires do
    collection do
      get :edit
      get :edit_quiz
      get :new
      get :new_quiz
      get :view
      post :update
      post :update_quiz
      post :update
      post :create
      post :create_quiz_questionnaire
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

  resources :reports, only: [] do
    collection do
      post :response_report
      get :response_report
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
      get :json
      post :send_email
      get :author
      get :run_get_notification
      post :edit
      post :delete
    end
  end

  resources :review_bids do
    collection do
      post :assign_bidding
      post :set_priority
      post :index
      post :run_bidding_algorithm
      get :show
    end
  end

  resources :review_mapping, only: [] do
    collection do
      get :add_calibration
      get :list_mappings
      get :unsubmit_review
      post :add_reviewer
      post :add_metareviewer
      post :add_user_to_assignment
      post :assign_metareviewer_dynamically
      post :automatic_review_mapping
      post :automatic_review_mapping_staggered
      post :assign_reviewer_dynamically
      post :assign_quiz_dynamically
      post :start_self_review
      post :save_grade_and_comment_for_reviewer
      post :delete_reviewer
      post :delete_metareview
      post :delete_metareviewer
      post :delete_all_metareviewers
      post :delete_outstanding_reviewers
    end
  end

  resources :roles do
    collection do
      get :list
      post ':id', action: :update
      post :update
      post :destroy
    end
  end

  resources :sample_reviews

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
      get :show_team
      get :switch_original_topic_to_approved_suggested_topic
      get :team_details
      get :intelligent_sign_up
      get :intelligent_save
      get :signup_as_instructor
      get :delete_signup_as_instructor
      post :delete_all_topics_for_assignment
      post :signup_as_instructor_action
      post :set_priority
      post :save_topic_deadlines
      post :delete_all_selected_topics
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
      put :publishing_rights_update
      get :email_reviewers
      post :send_email
      # added a new route for updating publishing rights
      get '/*other', to: redirect('/student_task/list')
    end
  end

  resources :student_task do
    collection do
      post :update
    end
  end

  resources :course_team do
    collection do
      get :list
    end
  end

  resources :student_teams, only: %i[create edit update] do
    collection do
      get :view
      get :remove_participant
      get :auto_complete_for_user_name
      get :edit
      post :update
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
      get :student_edit
      get :add_comment
      get :student_view
    end
  end

  resources :survey_deployment, only: %i[new create] do
    collection do
      get :list
      get :reminder_thread
      get :pending_surveys
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
      post :create_teams
      post :inherit
      get :delete
      get :delete_all
      get :bequeath_all
    end
  end

  resources :teams_users, only: %i[new create update] do
    collection do
      post :list
      post :update_duties
      get :delete
      post :delete_selected
    end
  end
  resources :popup do
    collection do
      get :reviewer_details_popup
      get :team_users_popup
      get :view_review_scores_popup
      get :self_review_popup
      get :author_feedback_popup
    end
  end

  resources :tag_prompts, except: %i[new edit]
  resources :track_notifications, only: [:index]

  resources :tree_display, only: [] do
    collection do
      post :list
      get :get_folder_contents
      post :get_sub_folder_contents
      get :session_last_open_tab
      get :set_session_last_open_tab
      get :goto_courses
      get :goto_assignments
      get :goto_questionnaires
      get :goto_review_rubrics
      get :goto_metareview_rubrics
      get :goto_teammatereview_rubrics
      get :goto_author_feedbacks
      get :goto_global_survey
      get :goto_surveys
      get :goto_course_surveys
      get :goto_bookmarkrating_rubrics
      get :list
      get :drill
    end
  end

  resources :users, constraints: { id: /\d+/ } do
    collection do
      get :list
      post :list
      post ':id', action: :update
      post :show_if_authorized
      get :auto_complete_for_user_name
      get :set_anonymized_view
      get :keys
      delete :destroy
      get :edit
      get :show
    end
  end

  resources :account_request, constraints: { id: /\d+/ } do
    collection do
      get :list
      post :list
      post :list_pending_requested
      post :list_pending_requested_finalized
      post ':id', action: :update
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

  resources :pair_programming, only: [] do
    collection do
      get :send_invitations
      get :accept
      get :decline
    end
  end

  resources :badges do
    collection do
      post :create
      get :redirect_to_assignment
      get :new
    end
  end

  resources :conference
  root to: 'content_pages#view', page_name: 'home'
  post :login, to: 'auth#login'
  post :logout, to: 'auth#logout'
  get 'auth/failure', to: 'content_pages#view'
  get '/auth/*path', to: redirect('/')
  get '/menu/*name', controller: :menu_items, action: :link
  get ':page_name', controller: :content_pages, action: :view, method: :get
  post 'impersonate/impersonate', to: 'impersonate#impersonate'
  post '/plagiarism_checker_results/:id' => 'plagiarism_checker_comparison#save_results'
  get 'instructions/home'
  get 'response/', to: 'response#saving'
  # get ':controller/service.wsdl', action: 'wsdl'
  get 'password_edit/check_reset_url', controller: :password_retrieval, action: :check_reset_url
  # get ':controller(/:action(/:id))(.:format)'
  unless Rails.env.development?
    match '*path' => 'content_pages#view', :via => %i[get post]
  end
  post '/response_toggle_permission/:id' => 'response#toggle_permission'
  post '/sample_reviews/map/:id' => 'sample_reviews#map_to_assignment'
  post '/sample_reviews/unmap/:id' => 'sample_reviews#unmap_from_assignment'
  post 'student_task/publishing_rights_update', controller: :student_task, action: :publishing_rights_update, method: :put
  get 'student_view/flip_view', controller: :student_view, action: :flip_view
  # updated route and added specific controller action upon accessing this route
end
