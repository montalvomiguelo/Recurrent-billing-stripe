Rails.application.routes.draw do
  mount StripeEvent::Engine, at: '/webhooks/stripe'

  devise_for :users

  resource :subscription
  resources :products

  root to: "products#index"
end
