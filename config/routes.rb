Rails.application.routes.draw do
  get 'home/index'

  root to: "home#index"

  devise_for :users, path_names: {
               sign_in: 'login', sign_out: 'logout',
               edit: 'settings'
             }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
