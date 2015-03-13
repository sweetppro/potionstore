Potionstore::Application.routes.draw do
  get 'store' => 'store/order#new'
  get '' => 'store/order#index'
  
  post 'admin/login' => 'admin#login'
  post 'order/payment' => 'store/order#payment'
  
    #paypal wps
    post '/notification/paypal_wps' => 'store/notification#paypal_wps'
    get '/order/wps_thankyou' => 'store/order#wps_thankyou'
  
  scope "store" do
    get "order/purchase" => "store/order#purchase"
    get "order/thankyou" => "store/order#thankyou"
    get "order/receipt" => "store/order#receipt"
    get "order/purchase_paypal" => "store/order#purchase_paypal"
    get "order/confirm_paypal" => "store/order#confirm_paypal"
    resources :order, :singular => true, :module => "store"
    
    # lost license routes
    get 'lost_license' => 'store/lost_license#index'
    post 'lost_license/retrieve' => 'store/lost_license#retrieve'
    get 'lost_license/sent' => 'store/lost_license#sent'

    # google checkout
    get 'notification/gcheckout' => 'store/notification#gcheckout'
  end

  namespace :admin do
    resources :products
    resources :coupons
    get 'coupons/:id/:operation' => 'coupons#toggle_state', :constraints => { :operation => /disable|enable/ }, :as => 'disable_coupon'
    get 'coupons/:id/toggle_state_for_all_coupons_with_code/:operation' => 'coupons#toggle_state_for_all_coupons_with_code', :constraints => { :operation => /disable|enable/ }, :as => 'toggle_state_for_all_coupons_with_code'
    #match 'coupons/:id/delete_all' => 'coupons#delete_all_coupons_with_code', :as => 'delete_all_coupons_with_code'
    resources :orders do
      member do
        get :cancel
        get :uncancel
        get :refund
        get :send_emails
      end
    end
  end

  get 'bugreport/crash' => 'email#crash_report'
  get '/:controller(/:action(/:id))'
  get '*path', via: :all, to: 'pages#error_404'
end