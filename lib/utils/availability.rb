module Utils
  module Availability
    def self.all_available_users(availability)
      availability.values.map(&:keys).flatten.uniq
    end

    # adds an interval (most likely a previously popped interval) to the availability hash
    def self.add_interval(availability, day, user, interval)
      availability[day] ||= {}
      availability[day][user] ||= []

      # We check if the interval overlaps or is adjacent to an existing interval
      # that's common when we add an interval with the assign_user_to_hours_interval method
      merged = false
      availability[day][user].each_with_index do |existing_interval, index|
        next unless Utils::Interval.overlap_or_adjacent?(existing_interval, interval)

        # Merge the intervals and replace the existing one
        availability[day][user][index] = Utils::Interval.merge(existing_interval, interval)
        merged = true
        break
      end

      availability[day][user] << interval unless merged

      availability[day][user].shuffle!
    end

    # we select (and pop) the last interval in the availability hash
    # since the availability hash was shuffled in initialization, we can be sure it'll be a random interval
    def self.pop_interval(availability, day, user)
      return nil unless availability[day] && availability[day][user]

      chosen_interval = availability[day][user].pop

      # we clear that day if no users available for that day, that means no modifications can be done to that day
      availability[day].delete(user) if availability[day][user].empty?

      chosen_interval
    end

    def self.remove_interval(availability, day, user, interval_to_remove)
      # we first check that the availability hash has the day and the user, and that the interval is valid
      raise ArgumentError, 'invalid interval' unless interval_to_remove.is_a?(Array) && interval_to_remove.length == 2
      return nil unless availability[day] && availability[day][user]

      removed_interval = availability[day][user].delete(interval_to_remove)

      availability[day].delete(user) if availability[day][user].empty?

      removed_interval
    end
  end
end
