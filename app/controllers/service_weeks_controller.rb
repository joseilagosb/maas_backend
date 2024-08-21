class ServiceWeeksController < ApplicationController
  def show
    service_week = ServiceWeek.includes(service_days: { service_hours: [:designated_user] })
                              .find_by(service_id: params[:service_id], week: params[:id])

    render json: ServiceWeekSerializer.new(service_week, {
                                             include: %i[
                                               service_days
                                               service_days.service_hours
                                               service_days.service_hours.designated_user
                                             ],
                                             params: { method: :show }
                                           }).serializable_hash, status: :ok
  end

  def edit
    service_week = ServiceWeek.includes(service_days: { service_hours: [:users] })
                              .find_by(service_id: params[:service_id], week: params[:id])
    render json: ServiceWeekSerializer.new(service_week, {
                                             include: %i[
                                               service_days
                                               service_days.service_hours
                                               service_days.service_hours.users
                                             ],
                                             params: { method: :edit }
                                           }).serializable_hash, status: :ok
  end

  def update
    parsed_availability = JSON.parse(update_params[:availability])
    ShiftSchedulerService.new(params[:service_id],
                              parsed_availability,
                              params[:id]).call

    render json: { error: 'Not implemented' }, status: :not_implemented
  end

  private

  def update_params
    params.require(:service_week).permit(:service_id, :availability, :week)
  end
end
