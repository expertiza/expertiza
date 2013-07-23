Expertiza::Application.routes.draw do
  resources :pages do
    collection do
      get :home
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
end
