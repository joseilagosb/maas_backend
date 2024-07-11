class ServicesController < ApplicationController
  before_action :check_admin, only: %i[new create]

  def index
    render json: 'hello world'
  end

  def new
    render json: 'hello you must be an admin'
  end

  def create
    render json: 'hello you must be an admin'
  end

  private

  def check_admin
    unless current_user.admin?
      render json: 'nope you are not an admin', status: :unauthorized
    end
  end
end
