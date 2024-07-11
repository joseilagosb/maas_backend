module AdminAuthorizable
  extend ActiveSupport::Concern

  private

  def check_admin
    unless current_user.admin?
      render json: 'nope you are not an admin', status: :unauthorized
    end
  end
end