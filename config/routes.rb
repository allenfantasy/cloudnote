Rails.application.routes.draw do
  resources :notes, only: [:index, :new, :create]
end
