# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :authentications, only: [:create]
      delete :authentications, action: :destroy, controller: :authentications

      resources :users
    end
  end
end
