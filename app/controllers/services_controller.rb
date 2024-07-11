class ServicesController < ApplicationController
  before_action :check_admin, only: %i[create]

  def index
    services = Service.all
    render json: services, status: :ok                                    
  end

  def create
    service = Service.new(service_params)
    if service.save!
      render json: service
    else
      render json: service.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def service_params
    params.require(:service).permit(:name, :from, :to)
  end
end
