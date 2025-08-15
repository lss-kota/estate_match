Rails.application.routes.draw do
  devise_for :users
  root "pages#index"
  get "pages/index"
  
  # Authenticated user routes
  get "dashboard", to: "dashboard#index"
  
  # Properties routes
  resources :properties, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    collection do
      # 簡単STEP投稿（5ステップ）
      get :new_step1, to: 'properties#new_step1'  # 取引種別
      post :save_step1, to: 'properties#save_step1'
      get :new_step2, to: 'properties#new_step2'  # 基本情報
      post :save_step2, to: 'properties#save_step2'
      get :new_step3, to: 'properties#new_step3'  # 所在地
      post :save_step3, to: 'properties#save_step3'
      get :new_step4, to: 'properties#new_step4'  # 価格
      post :save_step4, to: 'properties#save_step4'
      get :new_step5, to: 'properties#new_step5'  # 確認・投稿
      post :create_from_steps, to: 'properties#create_from_steps'
      
      delete :clear_session, to: 'properties#clear_session'
    end
    
    # お気に入り機能
    resource :favorite, only: [:create, :destroy]
  end
  
  # お気に入り一覧
  resources :favorites, only: [:index]
  
  # 不動産業者向け機能
  resources :partnerships, only: [:index, :show, :create, :destroy] do
    member do
      patch :approve
      patch :reject
    end
  end
  
  resources :inquiries, only: [:index, :show, :create] do
    member do
      patch :start_conversation
    end
  end
  
  # メッセージ機能
  resources :conversations, only: [:index, :show, :create, :destroy] do
    resources :messages, only: [:create] do
      member do
        patch :mark_as_read
      end
      collection do
        patch :mark_all_read
      end
    end
  end
  
  # Owner property management
  get "my_properties", to: "my_properties#index"
  
  # Legal pages
  get "terms", to: "legal#terms"
  get "privacy", to: "legal#privacy"
  get "company", to: "legal#company"
  get "tokutei", to: "legal#tokutei"
  
  # Admin routes
  namespace :admin do
    get 'auth', to: 'auth#verify'
    post 'auth', to: 'auth#verify'
    delete 'auth/logout', to: 'auth#logout'
    
    get 'dashboard', to: 'dashboard#index'
    root 'dashboard#index'
    
    # User management
    resources :users, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :toggle_status
      end
    end
    
    # Property management
    resources :properties, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :toggle_status
      end
    end
  end
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
