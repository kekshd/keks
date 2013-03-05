# encoding: utf-8

Keks::Application.routes.draw do
  resources :password_resets

  match "dot/:sha256.png", to: "dot#simple", :as => "render_dot", :via => :get
  match "latex/:base64_text.png", to: "latex#simple", :as => "render_tex", :via => :get
  match "preview", to: "latex#complex", :as => "render_preview", :via => :post



  root :to => "main#overview"

  get "main/overview"
  match "hitme", as: "main_hitme", to: "main#hitme"
  match "help", as: "main_help", to: "main#help"


  resources :users
  match "users/:id/enrollment" => "users#enroll", as: "enroll_user", via: :post
  match "users/:id/starred" => "users#starred", as: "starred", via: :get
  match "questions/:id/star" => "questions#star", as: "star_question", via: :get
  match "questions/:id/unstar" => "questions#unstar", as: "unstar_question", via: :get
  match "stats/:question_id/:answer_id" => "stats#new", as: "new_stat", via: :post


  get "admin/overview"
  scope "/admin" do
    resources :questions do
      resources :answers
      resources :hints
    end

    resources :categories
    match "category/:id/questions", to: "categories#questions", :as => "category_question", via: :get

    match "report/:enrollment_key", to: "stats#report", :as => "stat_report", via: :get
  end

  resources :sessions, only: [:new, :create, :destroy]


  match '/signup', to: 'users#new'
  match '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
