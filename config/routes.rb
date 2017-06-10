Rails.application.routes.draw do
  root to: 'dashboard#show'

  resources :currencies do
    resources :trades
  end

  get 'dashboard/charts'
  get 'charts/ticks'
end
