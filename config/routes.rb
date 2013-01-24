Wikireadability::Application.routes.draw do
  get "articles" => 'main#index'

  root :to => 'main#index'
end
