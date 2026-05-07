Rails.application.routes.draw do
  devise_for :users,
              path: "api/v1",
              path_names: {
                sign_in: "login",
                sign_out: "logout",
                registration: "signup"
              },
              controllers: {
                sessions: "api/v1/users/sessions",
                registrations: "api/v1/users/registrations"
              },
              defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      get "me", to: "users/me#show"
      patch "me", to: "users/me#update"

      resources :prompts, only: [ :index, :show, :create, :update, :destroy ]
   end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
