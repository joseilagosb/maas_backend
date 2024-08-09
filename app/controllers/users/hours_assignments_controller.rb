module Users
  class HoursAssignmentsController < ApplicationController
    def index
      hours_assignments = UserHoursAssignmentsQuery.new(options: hours_assignments_params).call

      render json: UserHoursAssignmentSerializer.new(hours_assignments).serializable_hash, status: :ok
    end

    private

    def hours_assignments_params
      params.require(:hours_assignment).permit(:service_id, :week)
    end
  end
end
