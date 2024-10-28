class AvailableIntervalsCreator
  def self.build(availability)
    new(availability).to_intervals
  end

  def initialize(availability)
    raise ArgumentError, 'invalid availability' unless availability.is_a?(Hash)

    @availability = availability
  end

  def to_intervals
    @availability['serviceDays'].each_with_object({}) do |day, result|
      intervals_by_user = Hash.new { |hash, key| hash[key] = [] }
      prev_available = {}
      day['serviceHours'].each do |hour|
        process_hour(hour, intervals_by_user, prev_available)
        prev_available = hour['available']
      end
      result[day['day']] = intervals_by_user.transform_values(&:shuffle)
    end
  end

  private

  def process_hour(hour, intervals_by_user, prev_available)
    hour['available'].each do |user_id, available|
      next unless available

      current_interval = find_or_initialize_interval(user_id, hour['hour'], intervals_by_user, prev_available)
      update_interval_end(current_interval, hour['hour'])
      intervals_by_user[user_id] << current_interval
    end
  end

  def find_or_initialize_interval(user_id, hour, intervals_by_user, prev_available)
    if !intervals_by_user[user_id].empty? && (prev_available[user_id] != false)
      intervals_by_user[user_id].pop
    else
      [hour, hour]
    end
  end

  def update_interval_end(interval, hour)
    interval[1] = hour if interval[1] == hour - 1
  end
end
