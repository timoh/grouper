Rails.application.routes.draw do
  resources :students
  root to: 'visitors#index'
end
