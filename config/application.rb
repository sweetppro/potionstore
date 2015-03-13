require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Potionstore
  class Application < Rails::Application      
    # Enable the asset pipeline
    config.assets.enabled = true
    
    config.active_record.whitelist_attributes = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.precompile += ['*.css', '*.js']
    
    # Change the path that assets are served from
    # config.assets.prefix = "/assets"
    
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :cc_number, :cc_code, :cc_month, :cc_year]
  end
end