Unlockherfreedom::Application.routes.draw do
  
  resources :posts


  devise_for :admins

  resources :payments
  resources :messages

  root to: 'pages#home'
  match 'who' => 'pages#who'
  match 'what' => 'pages#what'
  match 'why' => 'pages#why'
  match 'donate' => 'pages#donate'
  match 'involved' => 'pages#involved'

  devise_scope :admin do
    get 'sign-in' => 'devise/sessions#new', as: 'sign_in'
  end

end
