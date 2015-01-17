Richard::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  root to: 'queue_transactions#index'

  resources :queue_transactions do
    member do
      put 'force_release'
    end
    collection do
      post 'cancel'
      post 'run'
      post 'finish'
      get 'pending_next'
    end
  end

  get  "users", to: 'users#index'
  get  "user/api_key", to: 'users#api_key'
  post "user/reset_api_key", to: 'users#reset_api_key'
end
