Potionstore::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

    # In the development environment your application's code is reloaded on
    # every request. This slows down response time but is perfect for development
    # since you don't have to restart the web server when you make code changes.
    config.cache_classes = false

    config.eager_load = false

    # Show full error reports and disable caching
    config.consider_all_requests_local       = false
    config.action_controller.perform_caching = true

    # Don't care if the mailer can't send
    config.action_mailer.raise_delivery_errors = false

    # Print deprecation notices to the Rails logger
    config.active_support.deprecation = :log

    # Only use best-standards-support built into browsers
      config.action_dispatch.best_standards_support = :builtin
  
      # Do not compress assets
      config.assets.compress = true

      # Expands the lines which load the assets
      config.assets.debug = false
  
      # Disable Rails's static asset server
      # In production, Apache or nginx will already do this
      config.serve_static_files = true
  
      # Don't fallback to assets pipeline if a precompiled asset is missed
      config.assets.compile = true
  
      # Generate digests for assets URLs.
      config.assets.digest = true
  
      config.assets.initialize_on_precompile = false
  
      config.assets.logger = false
  
      # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
      # the I18n.default_locale when a translation can not be found)
      config.i18n.fallbacks = true

      # Send deprecation notices to registered listeners
      config.active_support.deprecation = :notify
  
      config.action_dispatch.x_sendfile_header = "X-Sendfile"
  end
