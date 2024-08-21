class ShiftSchedulerService
  def initialize(service_id, availability, week)
    @service_id = service_id
    @availability = availability
    @week = week
  end

  def call
    availability_intervals = to_intervals
    puts availability_intervals
  end

  private

  attr_reader :service_id, :availability, :week

  def to_intervals
    @availability['serviceDays'].each_with_object({}) do |day, result|
      intervals_by_user = Hash.new { |hash, key| hash[key] = [] }
      prev_available = {}
      day['serviceHours'].each do |hour|
        hour['available'].each do |user_id, available|
          next unless available

          current_interval = [hour['hour'], hour['hour']]
          unless intervals_by_user[user_id].empty? || (prev_available.key?(user_id) && prev_available[user_id] == false)
            current_interval = intervals_by_user[user_id].pop
          end

          current_interval[1] = hour['hour'] if current_interval[1] == hour['hour'] - 1

          intervals_by_user[user_id] << current_interval
        end
        prev_available = hour['available']
      end
      result[day['day']] = intervals_by_user
    end
  end
end
