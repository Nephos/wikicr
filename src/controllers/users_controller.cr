require "./application_controller"

class UsersController < ApplicationController
  # get /users/login
  def login
    acl_permit! :read
    render "login.slang"
  end

  # post /users/login
  def login_validates
    acl_permit! :write
    user = Wikicr::USERS.auth! params.body["username"].to_s, params.body["password"].to_s
    # TODO: make a notification
    if user.nil?
      flash["danger"] = "User or password doesn't match."
      redirect_to "/users/login"
    else
      flash["success"] = "You are connected!"
      session.string("user.name", user.name)
      set_login_cookies_for(user.name)
      redirect_to "/pages/home"
    end
  end

  # get /users/register
  def register
    acl_permit! :read
    render "register.slang"
  end

  # post /users/register
  def register_validates
    acl_permit! :write
    # TODO: make a notification
    begin
      user = Wikicr::USERS.register! params.body["username"].to_s, params.body["password"].to_s
      flash["success"] = "You are registrated under the username #{user.name}. You can connect now."
      redirect_to "/users/login"
    rescue err
      flash["danger"] = "Cannot register this account: #{err.message}."
      redirect_to "/users/register"
    end
  end
end
