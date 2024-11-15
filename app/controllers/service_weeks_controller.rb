class ServiceWeeksController < ApplicationController
  def show
    service_week = ServiceWeekFindOrCreateQuery.new(options: { service_id: params[:service_id], week: params[:id] },
                                                     includes: { service_days: { service_hours: [:designated_user] } })
                                                .call

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
    service_week = ServiceWeekFindOrCreateQuery.new(options: { service_id: params[:service_id], week: params[:id] },
                                                     includes: { service_days: { service_hours: [:users] } })
                                                .call
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
    parsed_availability_changes = JSON.parse(update_params[:availability_changes])
    current_user_id = update_params[:user_id]

    shifts = ShiftSchedulerService.new(parsed_availability,
                                       params[:service_id],
                                       params[:id]).call

    return render json: { error: 'Shifts could not be scheduled' }, status: :unprocessable_entity if shifts.blank?

    ActiveRecord::Base.transaction do
      service_week = ServiceWeek.find_by!(week: params[:id], service_id: params[:service_id])

      shifts.each do |day_number, hours|
        service_day = service_week.service_days.find_or_create_by!(day: day_number)

        hours.each do |hour_number, user_id|
          service_hour = service_day.service_hours.find_or_initialize_by(hour: hour_number)
          designated_user_id = user_id.presence&.to_i

          service_hour.designated_user_id = designated_user_id

          day_key = day_number.to_s
          hour_key = hour_number.to_s

          if parsed_availability_changes.key?(day_key) && parsed_availability_changes[day_key].key?(hour_key.to_s)
            current_user = User.find(current_user_id)
            if parsed_availability_changes[day_key][hour_key]['marked']
              service_hour.users << current_user
            else
              service_hour.users.delete(current_user)
            end
          end

          service_hour.save!
        end
      end

      render json: { message: 'Schedule updated successfully' }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError
      render json: { error: 'An unexpected error occurred' }, status: :internal_server_error
    end
  end

  private

  def update_params
    params.require(:service_week).permit(:service_id, :availability, :availability_changes, :week, :user_id)
  end
end
