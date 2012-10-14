Charactertome::Application.routes.draw do
  match "/404", :to => "errors#not_found"
  match "/422", :to => "errors#rejected"
  match "/500", :to => "errors#internal"
  root :to => "home#index"

  resources :tomes, :only => [:show, :update] do
    resources :goals, :only => [:create, :update] do
      resources :tasks, :only => [:create, :update]
    end

    collection do
      get "me"
    end
  end
end
