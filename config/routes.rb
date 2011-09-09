ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products
  
  
  map.resources :users, :collection => { :login => :get, 
                                         :signup => :get, 
                                         :logout => :get,
                                         :reset_password => :get,
                                         :edit_user => :get,
                                         :change_password => :get,
                                         :change_location => :get}
                                         
  map.resources :site, :collection => { :view_team => :get,
                                        :show_history => :get,
                                        :show_team_history => :get}
                                      
  map.resources :administration, :collection => { :add_team => :get,
                                                  :remove_team => :get,
                                                  :view_team => :get,
                                                  :edit_team => :get,
                                                  :add_member => :get,
                                                  :remove_member => :get,
                                                  :view_member_data => :get,
                                                  :save_competition => :post,
                                                  :delete_data => :get}
  
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  
  
  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => "site", :action => "index"
  # See how all your routes lay out with "rake routes"
  

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
