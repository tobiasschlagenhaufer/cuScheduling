Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

	root 'main#index'

	post '/' => 'main#index'
	get '/courses.json' => 'courses#index'
	get '/courses' => 'courses#index'
end
