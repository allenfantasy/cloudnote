Rails.application.routes.draw do
  resources :notes, only: [:index, :new, :create, :show]

  root 'home#index'
end
