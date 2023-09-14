Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post '/api/users', to: 'users#users'
  post '/api/authors', to: 'authors#authors'
  post '/api/books', to: 'books#books'

  # Defines the root path route ("/")
  # root "articles#index"
end
