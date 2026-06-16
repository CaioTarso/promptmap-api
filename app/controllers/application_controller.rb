class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers
  include Pagy::Backend
end
