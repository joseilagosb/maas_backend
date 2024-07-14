class UsersController < ApplicationController
  def index
    users = User.where(role: :user)
    render json: UserSerializer.new(users).serializable_hash, status: :ok
  end
end