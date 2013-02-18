Unlockherfreedom::Application.routes.draw do
  
  resources :payments
  resources :messages

  root to: 'pages#home'
  match 'who' => 'pages#who'
  match 'what' => 'pages#what'
  match 'why' => 'pages#why'
  match 'donate' => 'pages#donate'
  match 'involved' => 'pages#involved'

end


