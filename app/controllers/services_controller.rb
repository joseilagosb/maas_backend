class ServicesController < ApplicationController
  def index
    services = Service.all
    render json: ServiceSerializer.new(services, {
                                         params: { method: :index }
                                       }).serializable_hash, status: :ok
  end

  def show
    service = Service.includes(:service_weeks, :service_working_days).find_by(id: params[:id])
    render json: ServiceSerializer.new(service, {
                                         include: %i[service_weeks service_working_days],
                                         params: { method: :show }
                                       }).serializable_hash, status: :ok
  end

  private

  def service_params
    params.require(:service).permit(:id, :name, :active)
  end
end
