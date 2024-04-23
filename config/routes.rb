Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :notes
  resources :users
  resources :session
  resources :collections
  resources :friendships

  namespace :admin do
    resources :notes
    resources :users
    resources :collections
    resources :friendships
  end

  root :to => "home#index"
  get 'home', to: 'home#index'
  get 'about', to: 'about#index'
  get 'admin', to: 'admin#index'

  get "logout" => "session#destroy", :as => "logout"
  get "login" => "session#new", :as => "login"
  post "login" => "session#create"
  get "signup" => "users#new", :as => "signup"

  # Defines the root path route ("/")
  # root "posts#index"
end
