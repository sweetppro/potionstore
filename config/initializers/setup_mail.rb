# Include your application configuration below
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.delivery_method = :smtp

  ActionMailer::Base.smtp_settings = {
  :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
  :address => "localhost",
  :port => 26,
  :domain => "storedomain.com",
  :user_name => "info@storedomain.com",
  :password => "password",
  :authentication => :login
}