Charactertome::Application.routes.draw do
  root :to => "home#index"

  resources :tomes, :only => [:show]
end
