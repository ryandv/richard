Richard::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  root to: 'queue#index'

  scope :queue do
    post 'force_release/:id', to: 'queue#force_release', as: 'force_release'
    post 'grab', to: 'queue#grab'
    post 'release', to: 'queue#release'
    get 'is_next_in_line', to: 'queue#is_next_in_line'
  end

  get  "users", to: 'users#index'
  get  "user/api_key", to: 'users#api_key'
  post "user/reset_api_key", to: 'users#reset_api_key'
end
