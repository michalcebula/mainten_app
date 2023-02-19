# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :admin do
        resources :users, except: [:new, :edit]
      end

      resources :users, except: [:index, :new, :edit]

      resources :authentications, only: [:create]
      delete :authentications, action: :destroy, controller: :authentications
    end
  end
end
