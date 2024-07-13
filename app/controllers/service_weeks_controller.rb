class ServiceWeeksController < ApplicationController
  def show
    users = User.all.select(:id, :name, :color)
    service_week = ServiceWeek.find_by( service_id: params[:service_id], week: params[:id])
    render json: ServiceWeekSerializer.new(service_week, {
      include: [
        'service_days', 
        'service_days.service_hours', 
        'service_days.service_hours', 
        'service_days.service_hours.user'
      ]
    }).serializable_hash, status: :ok
  end

  private

  def service_week_params
    params.require(:service_week).permit(:id, :service_id, :week)
  end
end
