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

  private

  def service_week_params
    params.require(:service_week).permit(:id, :service_id, :week)
  end
end
