# encoding: utf-8

Keks::Application.routes.draw do
  resources :password_resets

  match "dot/:sha256.png", to: "dot#simple", :as => "render_dot", :via => :get
  match "preview", to: "latex#complex", :as => "render_preview", :via => :post



  root :to => "main#overview"

  get "main/overview"
  match "hitme", as: "main_hitme", to: "main#hitme"
  match "help", as: "main_help", to: "main#help"


  resources :users
  match "users/:id/enrollment" => "users#enroll", as: "enroll_user", via: :post
  match "users/:id/starred" => "users#starred", as: "starred", via: :get
  match "users/:id/history" => "users#history", as: "history", via: :get
  match "questions/:id/star" => "questions#star", as: "star_question", via: :get
  match "questions/:id/unstar" => "questions#unstar", as: "unstar_question", via: :get
  match "questions/:id/perma" => "questions#perma", as: "perma_question", via: :get
  match "stats/:question_id" => "stats#new", as: "new_stat", via: :post


  get "admin/overview"
  scope "/admin" do
    match "users", to: "users#index", as: "users", via: :get
    match "users/:id/reviews", to: "users#reviews", as: "user_reviews", via: :get
    match "toggle_reviewer/:id", to: "users#toggle_reviewer", as: "user_toggle_reviewer", via: :put
    match "toggle_admin/:id", to: "users#toggle_admin", as: "user_toggle_admin", via: :put

    match "reviews", to: "reviews#overview", as: "reviews", via: :get
    match "reviews/not_okay_questions", to: "reviews#not_okay", as: "not_okay_questions", via: :get
    match "reviews/no_reviews", to: "reviews#no_reviews", as: "no_reviews_questions", via: :get
    match "reviews/good_but_needs_more_reviews", to: "reviews#good_but_needs_more_reviews", as: "good_but_needs_more_reviews_questions", via: :get
    match "reviews/enough_good_reviews", to: "reviews#enough_good_reviews", as: "enough_good_reviews_questions", via: :get

    resources :questions do
      resources :answers
      resources :hints
      match "review", to: "reviews#review", as: "review", via: :get
      match "review", to: "reviews#save", as: "review_save", via: :post # new reviews
    end


    resources :categories
    match "categories/:id/release", to: "categories#release", :as => "release_category", via: :get
    match "report/:enrollment_key", to: "stats#report", :as => "stat_report", via: :get

    match "tree.svgz", to: "admin#tree", :as => "tree", via: :get
    match "export", to: "admin#export", :as => "export", via: :get
  end

  #~ match "category/:id/questions", to: "categories#questions", :as => "category_question", via: :get
  match "main/questions", to: "main#questions", :as => "main_question", via: :get
  match "main/single_question", to: "main#single_question", :as => "main_single_question", via: :get
  match "feedback", to: "main#feedback", :as => "feedback", via: :get
  match "feedback_send", to: "main#feedback_send", :as => "feedback_send", via: :post
  match "random_xkcd", to: "main#random_xkcd", :as => "random_xkcd", via: :get

  resources :sessions, only: [:new, :create, :destroy]


  match '/signup', to: 'users#new'
  match '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy'

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
