Rails.application.routes.draw do
  # API routes
  namespace :api do
    namespace :v1 do
      # 認証
      namespace :auth do
        post 'login', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'
        get 'me', to: 'sessions#me'
      end
      
      # フィードバック
      resources :feedbacks do
        member do
          patch 'read'           # 既読マーク
        end
        resource :reaction, only: [:create, :destroy]  # リアクション管理
        collection do
          get 'received'         # 受信フィードバック
          get 'sent'             # 送信フィードバック
        end
      end
      
      # ユーザー
      resources :users, only: [:index, :show, :update] do
        member do
          get 'stats'           # 個人統計
        end
      end
      
      # 組織
      resource :organization, only: [:show] do
        member do
          get 'users'           # 組織メンバー一覧
        end
      end

      # 統計
      resources :statistics, only: [:index]

      # ヘルスチェック
      get 'health', to: 'health#show'
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
