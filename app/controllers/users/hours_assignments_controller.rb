module Users
  class HoursAssignmentsController < ApplicationController
    before_action :validate_params, only: %i[index]

    def index
      hours_assignments = UserHoursAssignmentsQuery.new(options: hours_assignments_params).call

      render json: UserHoursAssignmentSerializer.new(hours_assignments).serializable_hash, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def validate_params
      if params[:hours_assignment].present? &&
         params[:hours_assignment][:service_id].present? &&
         params[:hours_assignment][:week].present?
        return
      end

      render json: { error: 'Missing parameters' }, status: :bad_request
    end

    def hours_assignments_params
      params.require(:hours_assignment).permit(:service_id, :week)
    end
  end
end
