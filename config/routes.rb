Richard::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  root to: 'queue#index'

  scope :queue do
    post 'force_release/:id', to: 'queue#force_release', as: 'force_release'
    post 'enqueue', to: 'queue#enqueue'
    post 'cancel', to: 'queue#cancel'
    post 'run', to: 'queue#run'
    post 'finish', to: 'queue#finish'
    get 'pending_next', to: 'queue#pending_next'
  end

  get  "users", to: 'users#index'
  get  "user/api_key", to: 'users#api_key'
  post "user/reset_api_key", to: 'users#reset_api_key'
end
