Rails.application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  root to: "courses#index"
  get :home, to: "home#index"
  resources :courses do
    # courses/:id/subscribe
    member do
      get :subscribe
    end
	  resources :tasks, only: [:show] do
	    member do
	      put :complete
	    end
	  end
    resources :reviews, only: [:create, :destroy]
  end
  get "/my_courses", to: "courses#my_courses"
  post "/payment_notification", to: "courses#payment_notification"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
