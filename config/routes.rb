Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # URLs de los recursos con vistas
  resources :notes
  resources :users
  resources :collections
  resources :friendships

  # URLs de CRUD para el admin
  namespace :admin do
    resources :notes
    resources :users
    resources :collections
    resources :friendships
  end

  root :to => "home#index"

  # as => "login" creates a login_path or login_url helper

  # Paginas estaticas sin nada mas
  get 'home', to: 'home#index', as: 'home'
  get 'about', to: 'about#index', as: 'about'
  get 'admin', to: 'admin#index', as: 'admin'

  # Inicio y desconexion de sesion
  get 'login', to: 'session#new', as: 'login'
  post 'login', to: 'session#create', as: 'login_post' 
  get 'logout', to: 'session#destroy', as: 'logout' 

  # Registro de usuarios
  get 'signup', to: 'users#new', as: 'signup'
  
  # URL que no sean resources ya que no tienen vistas
  get 'getNotifications', to: 'notifications#index', as: 'get_notifications'
  delete 'deleteNotification/:id', to: 'notifications#destroy', as: 'deleteNotification'
  

end
