# This files creates the main controller which is inherited by any other controller.
# It also loads the controller and helpers.

require "http"
require "./application_controller/**"
require "./helpers/**"

# The ApplicationController is the class that handles the environment:
# it handles the session, request, response, params, flash notices, cookies, redirections, and rendering.
class ApplicationController
  LAYOUT = "application.slang"
  include ApplicationController::Render
  include ApplicationController::Session
  include ApplicationController::Request
  include ApplicationController::Response
  include ApplicationController::Params
  include ApplicationController::Flash
  include ApplicationController::Cookies
  include ApplicationController::Redirect

  include Wikicr::Helpers::User
  include Wikicr::Helpers::Page
  include Wikicr::Helpers::History

  getter env : HTTP::Server::Context

  def initialize(@env)
  end
end

require "./**"
