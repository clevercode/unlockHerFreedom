Unlockherfreedom::Application.routes.draw do
  
  resources :conversations

  resources :payments

  root to: 'pages#home'
  match 'who' => 'pages#who'
  match 'what' => 'pages#what'
  match 'why' => 'pages#why'
  match 'donate' => 'pages#donate'
  match 'involved' => 'pages#involved'

end


