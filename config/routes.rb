Richard::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  resources :queue_transactions do
    member do
      put 'cancel'
      put 'run'
      put 'finish'
    end
    collection do
      get 'pending_next'
    end
  end

  match 'start_waiting/:id' => 'users#start_waiting'
  match 'stop_waiting/:id' => 'users#stop_waiting'
  match 'run_gorgon/:id' => 'users#run_gorgon'
  match 'finish_running/:id' => 'users#finish_running'

  root :to => 'queue_transactions#index'
  match 'users_json' => 'users#users_json'
end
