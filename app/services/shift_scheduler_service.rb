class ShiftSchedulerService
  attr_reader :service_id, :availability, :week

  def initialize(service_id, availability, week)
    @service_id = service_id
    @availability = availability
    @week = week
  end

  def call
    availability_intervals = IntervalManager.build_intervals(@availability)
    calculate_initial_shifts(availability_intervals)
  end

  private

  def calculate_initial_shifts(intervals)
    puts intervals
    puts 'calculate_initial_shifts'
  end

  def hours_in_week
    @availability['serviceDays'].sum { |day| day['serviceHours'].size }
  end
end
