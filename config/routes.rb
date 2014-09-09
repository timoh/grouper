Rails.application.routes.draw do
  resources :students
  root to: 'visitors#index'
  get '/groups' => 'visitors#groups'
end
