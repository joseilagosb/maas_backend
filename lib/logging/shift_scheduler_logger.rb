module Logging
  class ShiftSchedulerLogger
    def self.call(shifts, remaining_hours_by_user, hours_by_user, remaining_hours, availability, additional_message = '')
      Rails.logger.info '-------------'
      Rails.logger.info 'SHIFT SCHEDULER RESULTS:'
      Rails.logger.info "(#{additional_message})" if additional_message.present?
      log_shifts(shifts)
      Rails.logger.info "remaining hours by user: #{remaining_hours_by_user}"
      Rails.logger.info "hours by user: #{hours_by_user}"
      Rails.logger.info "quedan #{remaining_hours} horas"
      Rails.logger.info "remaining availability: #{availability}"
      Rails.logger.info '-------------'
    end

    def self.log_shifts(shifts)
      shifts.each do |day, hours|
        Rails.logger.info "day: #{day}, hours: #{hours}"
      end
    end

    private_class_method :log_shifts
  end
end
