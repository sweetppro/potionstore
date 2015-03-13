# Load the rails application
require File.expand_path('../application', __FILE__)

require 'digest/md5'

# Initialize the rails application
Potionstore::Application.initialize!

ActionController::Base.relative_url_root = "/store"