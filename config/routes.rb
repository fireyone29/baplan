Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  authenticated :user do
    root 'goals#index', as: :authenticated_root
  end
  root "home#index"

  devise_for :users, path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               edit: 'settings'
             }

  resources :goals do
    resources :streaks, only: [:create, :edit, :destroy]
  end
end
