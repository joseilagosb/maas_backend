class IntervalsManager
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

  # adds an interval (most likely a previously popped interval) to the availability hash
  def self.add_interval(availability, day, user, interval)
    availability[day] ||= {}
    availability[day][user] ||= []

    # We check if the interval overlaps or is adjacent to an existing interval
    # that's common when we add an interval with the assign_user_to_hours_interval method
    merged = false
    availability[day][user].each_with_index do |existing_interval, index|
      next unless interval_overlap_or_adjacent?(existing_interval, interval)

      # Merge the intervals and replace the existing one
      availability[day][user][index] = merge_intervals(existing_interval, interval)
      merged = true
      break
    end

    availability[day][user] << interval unless merged

    availability[day][user].shuffle!
  end

  def self.remainder_between_intervals(bigger_interval, smaller_interval)
    return [nil, :equal] if bigger_interval == smaller_interval
    return [bigger_interval, :overlap_or_adjacent] unless interval_overlap_or_adjacent?(
      bigger_interval, smaller_interval
    )

    # the remainder is in the right bound of the bigger interval
    if smaller_interval[0] <= bigger_interval[0]
      [[smaller_interval[1] + 1, bigger_interval[1]], :right]
    # the remainder is in the left bound of the bigger interval
    elsif smaller_interval[1] >= bigger_interval[1]
      [[bigger_interval[0], smaller_interval[0] - 1], :left]
    else
      # the smaller interval is in the middle, so the difference are two intervals in the left and right bounds of
      # the interval
      [[[bigger_interval[0], smaller_interval[0] - 1],
        [smaller_interval[1] + 1, bigger_interval[1]]], :both]
    end
  end

  def self.remainder_between_intervals_compact(bigger_interval, smaller_interval)
    result = remainder_between_intervals(bigger_interval, smaller_interval)

    return nil if result[1] == :equal

    result[0]
  end

  def self.interval_overlap_or_adjacent?(interval1, interval2)
    interval1[1] >= interval2[0] - 1 && interval2[1] >= interval1[0] - 1
  end

  def self.merge_intervals(interval1, interval2)
    [[interval1[0], interval2[0]].min, [interval1[1], interval2[1]].max]
  end

  def self.shift_interval(interval, shift)
    [interval[0] + shift, interval[1] + shift]
  end

  private_class_method :interval_overlap_or_adjacent?, :merge_intervals
end
