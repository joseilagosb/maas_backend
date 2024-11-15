# Select query that creates a service week alongside its respective service days and service hours if they don't exist yet
# and returns the resulting service week to the caller
class ServiceWeekFindOrCreateQuery
  attr_accessor :options, :includes

  def initialize(options: {}, includes: nil)
    @options = options
    @includes = includes || {
      service_days: {
        service_hours: %i[designated_user users]
      }
    }

    validate_options!
  end

  def call
    ActiveRecord::Base.transaction do
      service_week = ServiceWeek.find_or_create_by!(
        week: options[:week],
        service_id: options[:service_id]
      )
      working_days = ServiceWorkingDay.where(service_id: options[:service_id])

      create_service_days(service_week, working_days)
      create_service_hours(service_week, working_days)

      ServiceWeek.includes(includes)
                 .where(id: service_week.id)
                 .order('service_days.day ASC, service_hours.hour ASC')
                 .first
    end
  end

  private

  def create_service_days(service_week, working_days)
    existing_days = service_week.service_days.pluck(:day)
    days_to_create = working_days.map(&:day) - existing_days

    return unless days_to_create.any?

    service_days_attributes = days_to_create.map { |day| { day:, service_week_id: service_week.id } }

    ServiceDay.insert_all(service_days_attributes) if service_days_attributes.any?
  end

  def create_service_hours(service_week, working_days)
    service_days = service_week.service_days.reload.index_by(&:day)

    hours_to_create = []

    working_days.each do |working_day|
      service_day = service_days[working_day.day]
      next unless service_day

      existing_hours = ServiceHour.where(service_day_id: service_day.id).pluck(:hour)

      (working_day.from..working_day.to).each do |hour|
        next if existing_hours.include?(hour)

        hours_to_create << { hour:, service_day_id: service_day.id }
      end
    end

    ServiceHour.insert_all!(hours_to_create) if hours_to_create.any?
  end

  def validate_options!
    raise ArgumentError, "invalid week: #{options[:week]}" if options[:week].nil?
    raise ArgumentError, "invalid service id: #{options[:service_id]}" if options[:service_id].nil?
  end
end
