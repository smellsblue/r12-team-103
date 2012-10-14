Charactertome::Application.routes.draw do
  match "/404", :to => "errors#not_found"
  match "/422", :to => "errors#rejected"
  match "/500", :to => "errors#internal"
  root :to => "home#index"

  resources :tomes, :only => [:show, :update] do
    resources :weapons, :only => [:create, :destroy, :update]

    resources :goals, :only => [:create, :destroy, :update] do
      resources :tasks, :only => [:create, :destroy, :update]
    end

    collection do
      get "me"
    end

    member do
      get "pic"
      get "update_pic"
    end
  end
end
