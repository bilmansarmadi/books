Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post '/api/users', to: 'users#users'
  post '/api/restaurants', to: 'restaurants#restaurants'

  # Defines the root path route ("/")
  # root "articles#index"
end
