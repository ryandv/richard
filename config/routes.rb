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
      get 'pending_next'
    end
  end

  root :to => 'queue_transactions#index'
  match 'users_json' => 'users#users_json'
end
