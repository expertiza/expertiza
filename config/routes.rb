Expertiza::Application.routes.draw do |map|
  resources :assessment360 do
    collection do
      get :one_course_all_assignments
    end
  end

  resources :assignment do
    collection do
      delete :delete
      post :remove_assignment_from_course
      get :associate_assignment_with_course
      get :toggle_access
      get :copy
    end
  end

  resources :auth do
    collection do
      post :login
      post :logout
    end
  end

  resources :content_pages

  resources :controller_actions

  resources :course do
    collection do
      post :delete
      post :toggle_access
      post :copy
      get :view_teaching_assistants
    end
  end

  resources :grades do
    collection do
      get :view
    end
  end

  resources :impersonate do
    collection do
      get :start
      post :impersonate
    end
  end

  resources :join_team_requests

  resources :leaderboard do
    collection do
      get :index
    end
  end

  resources :menu_items do
    collection do
      get :move_down
      get :move_up
      get :new_for
      get :link
    end
  end

  resources :participants do
    collection do
      get :list
    end
  end

  resources :password_retrieval do
    collection do
      get :forgotten
    end
  end

  resources :questionnaire do
    collection do
      get :view
      post :delete
      post :toggle_access
      post :copy
    end
  end

  resources :review_mapping do
    collection do
      get :list_mappings
      get :review_report
    end
  end

  resources :sign_up_sheet do
    collection do
      get :add_signup_topics
      get :add_signup_topics_staggered
      get :view_publishing_rights
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

  resources :team do
    collection do
      get :list
    end
  end

  resources :tree_display do
    collection do
      get :drill
      get :list
    end
  end

  match 'menu/:name', controller: :menu_items, action: :link, method: :get
  match ':page_name', controller: :content_pages, action: :view, method: :get

  root to: 'pages#home'

  map.connect 'question/select_questionnaire_type', :controller => "questionnaire", :action => 'select_questionnaire_type'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
end
