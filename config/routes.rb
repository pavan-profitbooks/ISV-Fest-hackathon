Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations',
    unlocks: 'users/unlocks'
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Resource routes
  resources :vendors
  resources :categories
  resources :expenses do
    member do
      patch :approve
      patch :reject
    end
  end

  # Reports routes
  resources :reports, only: [:index] do
    collection do
      get :expenses_by_date
      get :expenses_by_category
      get :expenses_by_vendor
      get :expenses_by_status
      get :top_vendors
      get :vendor_transactions
      get :category_trends
      get :category_summary
      get :unprocessed_receipts
      get :receipts_by_date
      get :monthly_trends
      get :year_comparison
      get :expense_summary
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#index"
end
