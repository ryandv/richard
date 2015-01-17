Richard::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  root to: 'queue_transactions#index'

  resources :queue_transactions do
    member do
      put 'cancel'
      put 'run'
      put 'finish'
      put 'force_release'
    end
    collection do
      get 'pending_next'
    end
  end

  namespace :api do
    resources :queue_transactions do
      member do
        put 'cancel'
        put 'run'
        put 'finish'
        put 'force_release'
      end
      collection do
        get 'pending_next'
        put 'enqueue'
      end
    end
  end

  get  "users", to: 'users#index'
  get  "user/api_key", to: 'users#api_key'
  post "user/reset_api_key", to: 'users#reset_api_key'
end
