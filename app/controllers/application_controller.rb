class ApplicationController < ActionController::API
  include Pagy::Backend

  before_action { request.format = :json }
end
