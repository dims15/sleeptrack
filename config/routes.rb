Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      post "/users", to: "users#create"
      post "/users/:user_id/follow/:following_user_id", to: "users#follow"
      delete "/users/:user_id/unfollow/:following_user_id", to: "users#unfollow"
      get "/users/:user_id/clock_in", to: "users#retrieve_clock_in"

      post "/sleep-track", to: "sleep_track#create"
      patch "/sleep-track/:id", to: "sleep_track#update"
      get "/following-sleep-track", to: "sleep_track#index"
      delete "/sleep-track/:id", to: "sleep_track#delete"
    end
  end
end
