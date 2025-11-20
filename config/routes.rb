Rails.application.routes.draw do
  root 'dashboard#index'
  
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  
  resources :vendors
  resources :categories
  resources :rules
  resources :receipts
  resources :expenses do
    member do
      patch :approve
      patch :reject
    end
  end
end
