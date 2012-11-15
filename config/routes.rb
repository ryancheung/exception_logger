ExceptionLogger::Engine.routes.draw do
  # Exception Logger
  resources :logged_exceptions do
    collection do
      post :clear
      post :query
      post :destroy_all
      get :feed
    end
  end

  root :to => 'logged_exceptions#index'
end
