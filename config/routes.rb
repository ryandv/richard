Richard::Application.routes.draw do

devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  match 'start_waiting/:id' => 'users#start_waiting'
  match 'stop_waiting/:id' => 'users#stop_waiting'
  match 'run_gorgon/:id' => 'users#run_gorgon'
  match 'finish_running/:id' => 'users#finish_running'

  root :to => 'users#index'
  match 'users_json' => 'users#users_json'
end
