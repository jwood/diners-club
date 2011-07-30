require 'app_config'

class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  htpasswd_file = AppConfig.instance.htpasswd_file
  htpasswd :file => htpasswd_file unless htpasswd_file.blank?

  layout 'standard'
end
