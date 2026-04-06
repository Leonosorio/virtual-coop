Rails.application.routes.draw do
  root "home#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :clients do
    member do
      patch :block
      patch :unblock
    end
  end

  resources :payments do
    collection do
      get :export
    end
  end
end