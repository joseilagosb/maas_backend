module Users
  class AssignedHoursController < ApplicationController
    def index
      assigned_hours = UserAssignedHoursQuery.new(options: user_assigned_hours_params).call

      render json: UserAssignedHoursSerializer.new(assigned_hours).serializable_hash, status: :ok
    end

    private

    def user_assigned_hours_params
      params.require(:user_assigned_hours).permit(:service_id, :week)
    end
  end
end
