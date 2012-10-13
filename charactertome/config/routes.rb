Charactertome::Application.routes.draw do
  root :to => "home#index"

  resources :tomes, :only => [:show, :update] do
    collection do
      get "me"
    end
  end
end
