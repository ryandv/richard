Richard::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  resources :queue_transactions do
    member do
      put 'cancel'
      put 'run'
      put 'finish'
      put 'force_release'
    end
    collection do
      get 'event'
      get 'pending_next'
      get 'current'
      get 'action_status'
      get 'user'
    end
  end

  root to: 'queue_transactions#index'
  get 'users_json' => 'users#users_json'
end
