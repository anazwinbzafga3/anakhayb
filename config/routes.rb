Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  # Error pages
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  devise_for :users, :skip => [:sessions,:registrations,:passwords], controllers: { sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords'}
  as :user do

    get "/login" => "users/sessions#new", :as => :new_user_session
    post "/login" => "users/sessions#create", :as => :user_session
    delete "/logout" => "users/sessions#destroy", :as => :destroy_user_session


    get "/signup" => "users/registrations#new", :as => :new_user_registration
    post "/signup" => "users/registrations#create", :as => :user_registration


    get "/password_reset" => "users/passwords#new", :as => :new_user_password
    put "/password_reset" => "users/passwords#update", :as => :user_password
    post "/password_reset" => "users/passwords#create"


    get "/settings" => "users/registrations#edit", :as => :edit_user_registration
    put "/settings" => "users/registrations#update"
    patch "/settings" => "users/registrations#update"
  end

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.email == "abdelmalek3a@gmail.com" } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'pages#homepage'
  get '/pricing' => "pages#pricing"
  get '/setup' => 'stores#new'
  post '/setup' => 'stores#create'
  get '/auth/shopify/callback' => 'stores#authorize', :as => :authorize
  get '/dashboard' => 'dashboards#overview'
  get '/payment' => "stores#payment", :as => :payment
  post '/payment/create' => "stores#create_payment", :as => :create_payment
  get '/exporting' => "dashboards#exporting", :as => :exporting
  get '/demo' => "pages#demo", :as => :demo

  # Webhooks

  post "/webhooks/orders/create/:store_id" => "webhooks#order_create"
  post "/webhooks/orders/update/:store_id" => "webhooks#order_update"
  post "/webhooks/customers/create/:store_id" => "webhooks#customer_create"
  post "/webhooks/customers/update/:store_id" => "webhooks#customer_update"



end
