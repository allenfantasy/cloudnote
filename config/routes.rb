Rails.application.routes.draw do
  resources :notes, only: [:index, :new, :create, :show, :delete] do
    collection do
      post :sync
    end
  end

  root 'home#index'
end
