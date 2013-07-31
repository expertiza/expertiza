Expertiza::Application.routes.draw do |map|
  match 'home', controller: :pages, action: :home
  match 'contact_us', controller: :pages, action: :contact_us
  match 'credits', controller: :pages, action: :credits

  resources :leaderboard do
    member do
      get :index
    end
  end

  resources :auth do
    collection do
      get :login
    end
  end

  resources :password_retrieval do
    collection do
      get :forgotten
    end
  end

  root to: 'pages#home'

  map.resources :join_team_requests
  map.connect 'question/select_questionnaire_type', :controller => "questionnaire", :action => 'select_questionnaire_type'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  map.connect ':controller/:action/:id'
end
